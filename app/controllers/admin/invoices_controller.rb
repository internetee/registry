class Admin::InvoicesController < AdminController
  load_and_authorize_resource

  def index
    @q = Invoice.search(params[:q])
    @q.sorts  = 'id desc' if @q.sorts.empty?
    @invoices = @q.result.page(params[:page])
  end

  def show
    @invoice = Invoice.find(params[:id])
  end
end
