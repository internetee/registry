class Registrar
  class AccountActivitiesController < BaseController
    load_and_authorize_resource

    def index
      params[:q] ||= {}
      account = current_registrar_user.registrar.cash_account

      ca_cache = params[:q][:created_at_lteq]
      begin
        end_time = params[:q][:created_at_lteq].try(:to_date)
        params[:q][:created_at_lteq] = end_time.try(:end_of_day)
      rescue StandardError
        logger.warn('Invalid date')
      end

      @q = account.activities.includes(:invoice).search(params[:q])
      @q.sorts = 'id desc' if @q.sorts.empty?

      respond_to do |format|
        format.html { @account_activities = @q.result.page(params[:page]) }
        format.csv do
          send_data @q.result.to_csv, filename: "account_activities_#{Time.zone.now.to_formatted_s(:number)}.csv"
        end
      end

      params[:q][:created_at_lteq] = ca_cache
    end
  end
end
