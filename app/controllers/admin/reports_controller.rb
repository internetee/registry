require 'active_record_result_combiner'

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

      if @report.update(params_to_update)
        redirect_to admin_report_path(@report), notice: t('.updated')
      else
        render :edit
      end
    end

    def destroy
      @report.destroy
      redirect_to admin_reports_path, notice: t('.deleted')
    end

    def run
      result = ReportRunner.run_report(@report, params[:report_parameters])

      case result[:status]
      when :completed
        @unified_results = result[:results]
        @page_title = result[:page_title]
        respond_to_format
      when :error
        flash[:alert] = "Error running report: #{result[:error]}"
        redirect_to admin_reports_path
      when :timeout
        flash[:alert] = 'Report execution timed out'
        redirect_to admin_reports_path
      end
    end

    def duplicate
      dup_report = @report.dup
      dup_report.name = "#{@report.name} (copy)"
      # Explicitly clone the parameters JSON to ensure it's properly copied
      dup_report.parameters = @report.parameters.to_json

      if dup_report.save
        redirect_to admin_report_path(dup_report), notice: t('.created')
      else
        redirect_to admin_report_path(@report), alert: 'Failed to duplicate report'
      end
    end

    def generate_with_ai
      return redirect_with_prompt_error if params[:prompt].blank?

      response = AiReportGenerator.new(params[:prompt], params[:schema]).generate

      if response[:success]
        create_report_from_ai_response(response)
      else
        redirect_to new_admin_report_path(ai: true), alert: "AI report generation failed: #{response[:error]}"
      end
    end

    private

    def redirect_with_prompt_error
      redirect_to new_admin_report_path(ai: true), alert: 'Please provide a description for the AI to generate a report'
    end

    def create_report_from_ai_response(response)
      result = response[:result].with_indifferent_access
      @report = build_report(result)
      ensure_unique_report_name

      if @report.save
        redirect_to admin_report_path(@report), notice: 'AI successfully generated your report'
      else
        flash.now[:alert] = "Failed to save the generated report: #{@report.errors.full_messages.join(', ')}"
        render :new
      end
    end

    def build_report(result)
      Report.new(
        name: result[:name],
        description: result[:description],
        sql_query: result[:sql_query],
        parameters: result[:parameters].to_json
      )
    end

    def ensure_unique_report_name
      return unless Report.exists?(name: @report.name)

      base_name = @report.name
      counter = 1
      counter += 1 while Report.exists?(name: "#{base_name} (#{counter})")
      @report.name = "#{base_name} (#{counter})"
    end

    def report_params
      params.require(:report).permit(:name, :description, :sql_query, :parameters)
    end

    def respond_to_format
      respond_to do |format|
        format.html
        format.csv do
          filename = "#{@page_title}_report".parameterize
          csv_data = generate_csv(@unified_results)
          send_data csv_data, filename: "#{filename}.csv"
        end
      end
    end

    def generate_csv(results)
      return '' if results.empty?

      CSV.generate(headers: true) do |csv|
        csv << results.columns
        results.rows.each do |row|
          csv << row
        end
      end
    rescue StandardError => e
      Rails.logger.error("CSV Generation Error: #{e.message}")
      ''
    end
  end
end
