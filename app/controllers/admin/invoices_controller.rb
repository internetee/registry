class Admin::InvoicesController < AdminController
  load_and_authorize_resource

  def index
    @q = Invoice.includes(:account_activity).search(params[:q])
    @q.sorts  = 'id desc' if @q.sorts.empty?
    @invoices = @q.result.page(params[:page])
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  def cancel
    if @invoice.cancel
      flash[:notice] = t(:record_updated)
      redirect_to([:admin, @invoice])
    else
      flash.now[:alert] = t(:failed_to_update_record)
      render :show
    end
  end
end
