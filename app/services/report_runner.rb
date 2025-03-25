module ReportRunner
  REPORT_TIMEOUT = 300 # 5 minutes timeout
  THREAD_CHECK_INTERVAL = 0.5 # Check thread status every 0.5 seconds

  class << self
    def run_report(report, params)
      thread = create_report_thread(report, params)
      monitor_thread(thread)
    end

    private

    def create_report_thread(report, params)
      Thread.new do
        Thread.current[:results] = nil
        Thread.current[:page_title] = nil

        ActiveRecord::Base.connection_pool.with_connection do
          begin
            results = execute_report(report, params)
            Thread.current[:results] = results
            Thread.current[:page_title] = build_page_title(report, params)
            Thread.current[:status] = :completed
          rescue => e
            Thread.current[:error] = e.message
            Thread.current[:status] = :error
            Rails.logger.error("Report Error: #{e.message}\n#{e.backtrace.join("\n")}")
          end
        end
      end
    end

    def execute_report(report, params)
      results = []

      if report.parameters.present?
        return [] if params.blank?

        params.each_value do |parameter_set|
          permitted_param_set = parameter_set.permit(report.parameters.keys)
          query = report.sql_query.dup
          handle_parameters(query, report, permitted_param_set)
          results << run_query(query)
        end
      else
        results << run_query(report.sql_query.dup)
      end

      ActiveRecordResultCombiner.combine_results(results)
    end

    def monitor_thread(thread)
      start_time = Time.current

      while Time.current - start_time < REPORT_TIMEOUT
        case thread[:status]
        when :completed
          return {
            status: :completed,
            results: thread[:results],
            page_title: thread[:page_title]
          }
        when :error
          return {
            status: :error,
            error: thread[:error]
          }
        end

        sleep THREAD_CHECK_INTERVAL
      end

      thread.kill
      { status: :timeout }
    ensure
      thread.kill if thread.alive?
    end

    def run_query(query)
      ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
        ActiveRecord::Base.connection.exec_query(sanitize_sql(query))
      end
    rescue StandardError => e
      Rails.logger.error("Query Error: #{e.message}\nQuery: #{query}")
      raise e
    end

    def sanitize_sql(query)
      ActiveRecord::Base.sanitize_sql_array([query])
    end

    def handle_parameters(query, report, params)
      return [] if report.parameters.blank?

      parameter_values = []
      report.parameters.each_key do |param|
        value = retrieve_parameter_value(param, params, report)
        substitute_query_param(query, param, value)
        parameter_values << "#{param.humanize}: #{value}" if params[param].present?
      end

      parameter_values
    end

    def substitute_query_param(query, param, value)
      query.gsub!(":#{param}", ActiveRecord::Base.connection.quote(value))
    end

    def retrieve_parameter_value(param, params, report)
      params[param].present? ? params[param] : report.parameters[param]['default']
    end

    def build_page_title(report, params)
      return report.name unless report.parameters.present? && params.present?

      parameter_values = params.to_unsafe_h.values.map do |param_set|
        param_set.map { |param, value| "#{param.humanize}: #{value}" if value.present? }.compact
      end.flatten

      parameter_values.any? ? "#{report.name} - #{parameter_values.join(', ')}" : report.name
    end
  end
end
