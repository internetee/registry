module Admin
  class ReportsController < BaseController
    load_and_authorize_resource

    # Show a list of available reports
    def index
      params[:q] ||= {}
      @q = Report.ransack(params[:q])
      @q.sorts = 'name asc' if @q.sorts.empty?
      @reports = @q.result.page(params[:page])
      @reports = @reports.per(params[:results_per_page]) if paginate?
    end

    def create
      @report = Report.new(report_params.merge(created_by: current_admin_user.id))

      if @report.save
        redirect_to admin_reports_path, notice: t('.created')
      else
        render :new
      end
    end

    def update
      params_to_update = report_params
      parse_json_parameters(params_to_update)

      if @report.update(params_to_update)
        redirect_to admin_reports_path, notice: t('.updated')
      else
        render :edit
      end
    end

    def destroy
      @report.destroy
      redirect_to admin_reports_path, notice: t('.deleted')
    end

    def run
      query = @report.sql_query
      parameter_values = handle_parameters(query)

      @page_title = build_page_title(parameter_values)
      @results = run_report(query)

      respond_to_format
    end

    private

    def report_params
      params.require(:report).permit(:name, :description, :sql_query, :parameters)
    end

    def run_report(query)
      ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
        ActiveRecord::Base.connection.exec_query(sanitize_sql(query))
      end
    rescue StandardError => e
      flash[:alert] = "Error running report: #{e.message}"
      []
    end

    def sanitize_sql(query)
      ActiveRecord::Base.sanitize_sql_array([query])
    end

    def parse_json_parameters(params_to_update)
      if params_to_update[:parameters].present? && params_to_update[:parameters].is_a?(String)
        params_to_update[:parameters] = JSON.parse(params_to_update[:parameters])
      else
        params_to_update[:parameters] = nil
      end
    rescue JSON::ParserError => e
      @report.errors.add(:parameters, "Invalid JSON format: #{e.message}")
      render :edit
    end

    # Generate CSV from ActiveRecord results
    def generate_csv(results)
      return '' if results.empty?

      CSV.generate(headers: true) do |csv|
        # Add headers from the columns
        csv << results.columns.map(&:humanize)

        # Add each row of data
        results.rows.each do |row|
          csv << row
        end
      end
    rescue StandardError => e
      Rails.logger.error("CSV Generation Error: #{e.message}")
      ''
    end

    def handle_parameters(query, parameter_values = [])
      return parameter_values if @report.parameters.blank?

      @report.parameters.each_key do |param|
        value = retrieve_parameter_value(param)
        substitute_query_param(query, param, value)
        parameter_values << "#{param.humanize}: #{value}" if params[param].present?
      end

      parameter_values
    end

    def substitute_query_param(query, param, value)
      query.gsub!(":#{param}", ActiveRecord::Base.connection.quote(value))
    end

    def retrieve_parameter_value(param)
      params[param].present? ? params[param] : @report.parameters[param]['default']
    end

    def build_page_title(parameter_values)
      if parameter_values.any?
        "#{@report.name} - #{parameter_values.join(', ')}"
      else
        @report.name
      end
    end

    def respond_to_format
      respond_to do |format|
        format.html
        format.csv do
          filename = "#{@page_title}_report.csv".parameterize
          send_data generate_csv(@results), filename: filename
        end
      end
    end
  end
end
