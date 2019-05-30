class Registrar
  class InvoicesController < BaseController
    load_and_authorize_resource

    def index
      params[:q] ||= {}
      invoices = current_registrar_user.registrar.invoices.includes(:items, :account_activity)

      normalize_search_parameters do
        @q = invoices.search(params[:q])
        @q.sorts = 'id desc' if @q.sorts.empty?
        @invoices = @q.result.page(params[:page])
      end
    end

    def show; end

    def cancel
      @invoice.cancel
      redirect_to [:registrar, @invoice], notice: t('.cancelled')
    end

    def download
      filename = "invoice-#{@invoice.number}.pdf"
      send_data @invoice.as_pdf, filename: filename
    end

    private

    def normalize_search_parameters
      params[:q][:total_gteq]&.tr!(',', '.')
      params[:q][:total_lteq]&.tr!(',', '.')
      yield
    end
  end
end
