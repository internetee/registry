class Registrar
  class InvoicesController < BaseController
    load_and_authorize_resource

    before_action :set_invoice, only: [:show, :forward, :download_pdf]

    def index
      params[:q] ||= {}
      invoices = current_registrar_user.registrar.invoices
                   .includes(:invoice_items, :account_activity)

      normalize_search_parameters do
        @q = invoices.search(params[:q])
        @q.sorts = 'id desc' if @q.sorts.empty?
        @invoices = @q.result.page(params[:page])
      end
    end

    def show;
    end

    def forward
      @invoice.billing_email = @invoice.buyer.billing_email

      return unless request.post?

      @invoice.billing_email = params[:invoice][:billing_email]

      if @invoice.forward(render_to_string('pdf', layout: false))
        flash[:notice] = t(:invoice_forwared)
        redirect_to([:registrar, @invoice])
      else
        flash.now[:alert] = t(:failed_to_forward_invoice)
      end
    end

    def cancel
      if @invoice.cancel
        flash[:notice] = t(:record_updated)
        redirect_to([:registrar, @invoice])
      else
        flash.now[:alert] = t(:failed_to_update_record)
        render :show
      end
    end

    def download_pdf
      pdf = @invoice.pdf(render_to_string('pdf', layout: false))
      send_data pdf, filename: @invoice.pdf_name
    end

    private

    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def normalize_search_parameters
      params[:q][:total_gteq].gsub!(',', '.') if params[:q][:total_gteq]
      params[:q][:total_lteq].gsub!(',', '.') if params[:q][:total_lteq]

      ca_cache = params[:q][:due_date_lteq]
      begin
        end_time = params[:q][:due_date_lteq].try(:to_date)
        params[:q][:due_date_lteq] = end_time.try(:end_of_day)
      rescue
        logger.warn('Invalid date')
      end

      yield

      params[:q][:due_date_lteq] = ca_cache
    end
  end
end
