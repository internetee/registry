module Admin
  class ReserveDomainInvoicesController < BaseController
    load_and_authorize_resource

    def index
      params[:q] ||= {}
      @q = ReserveDomainInvoice.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @reserve_domain_invoices = @q.result.page(params[:page])
    end

    def download
      send_data @reserve_domain_invoice.as_pdf(paid: @reserve_domain_invoice.paid?),
                filename: "invoice-#{@reserve_domain_invoice.invoice_number}.pdf",
                type: 'application/pdf'
    end
  end
end
