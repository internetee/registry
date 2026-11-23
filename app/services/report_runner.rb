require 'active_record_result_combiner'

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
      report_parameters = report.parameters.is_a?(Array) ? report.parameters : [report.parameters]

      if params.present?
        params.each_value do |parameter_set|
          # Build permit list - for array parameters (type: 'registrars'), we need to specify them as { param_name: [] }
          permit_list = report_parameters.map do |param|
            # Check if parameter type indicates an array (registrars, or any type ending with 's' that suggests plural)
            if param["type"] == "registrars" || (param["type"]&.end_with?("s") && param["type"] != "date")
              { param["name"] => [] }
            else
              param["name"]
            end
          end

          permitted_param_set = parameter_set.permit(*permit_list)
          query = report.sql_query.dup
          handle_parameters(query, permitted_param_set)
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
      if Rails.env.test?
        ActiveRecord::Base.connection.exec_query(query)
      else
        ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
          ActiveRecord::Base.connection.exec_query(query)
        end
      end
    rescue StandardError => e
      Rails.logger.error("Query Error: #{e.message}\nQuery: #{query}")
      raise e
    end

    def handle_parameters(query, param_set)
      parameter_values = []
      param_set.each_key do |param|
        value = param_set[param]
        substitute_query_param(query, param, value)
        parameter_values << "#{param.humanize}: #{value}" if value.present?
      end

      parameter_values
    end

    def substitute_query_param(query, param, value)
      if value.blank?
        # Replace :param with NULL for SQL compatibility
        query.gsub!(":#{param}", "NULL")
      elsif value.is_a?(Array)
        # Handle array values (from multiselect) - convert to PostgreSQL array format
        # For integer arrays (like registrar_ids), we need integers without quotes
        if param.to_s.include?('id') && value.all? { |v| v.to_s.match?(/^\d+$/) }
          array_values = value.map(&:to_i).join(',')
          query.gsub!(":#{param}", "ARRAY[#{array_values}]")
        else
          # For string arrays, use quotes
          array_values = value.map { |v| ActiveRecord::Base.connection.quote(v) }.join(',')
          query.gsub!(":#{param}", "ARRAY[#{array_values}]")
        end
      else
        query.gsub!(":#{param}", ActiveRecord::Base.connection.quote(value))
      end
    end

    def build_page_title(report, params)
      return report.name unless params.present?

      parameter_values = params.to_unsafe_h.values.map do |param_set|
        param_set.map { |param, value| "#{param.humanize}: #{value}" if value.present? }.compact
      end.flatten

      parameter_values.any? ? "#{report.name} - #{parameter_values.join(', ')}" : report.name
    end
  end
end
