class Registrar::AccountActivitiesController < RegistrarController
  load_and_authorize_resource

  # before_action :set_invoice, only: [:show]

  def index
    account = current_user.registrar.cash_account
    @q = account.activities.includes(:invoice).search(params[:q])
    @q.sorts  = 'id desc' if @q.sorts.empty?
    @account_activities = @q.result.page(params[:page])
  end

  def show
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end
end
