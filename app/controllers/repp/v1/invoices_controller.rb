require 'serializers/repp/invoice'
module Repp
  module V1
    class InvoicesController < BaseController
      load_and_authorize_resource

      api :get, '/repp/v1/invoices'
      desc 'Get all invoices'
      def index
        records = current_user.registrar.invoices

        q = records.ransack(search_params)
        q.sorts = 'created_at desc' if q.sorts.empty?
        invoices = q.result(distinct: true)

        limited_invoices = invoices.limit(limit).offset(offset)
                                   .includes(:items, :account_activity, :buyer)

        render_success(data: { invoices: serialized_invoices(limited_invoices),
                               count: invoices.count })
      end

      api :get, '/repp/v1/invoices/:id'
      desc 'Get a specific invoice'
      def show
        serializer = Serializers::Repp::Invoice.new(@invoice)
        render_success(data: { invoice: serializer.to_json })
      end

      api :get, '/repp/v1/invoices/:id/download'
      desc 'Download a specific invoice as pdf file'
      def download
        filename = "Invoice-#{@invoice.number}.pdf"
        @response = { code: 1000, message: 'Command completed successfully',
                      data: filename }
        send_data @invoice.as_pdf, filename: filename
      end

      api :post, '/repp/v1/invoices/:id/send_to_recipient'
      desc 'Send invoice pdf to recipient'
      def send_to_recipient
        recipient = invoice_params[:recipient]
        InvoiceMailer.invoice_email(invoice: @invoice, recipient: recipient)
                     .deliver_now
        serializer = Serializers::Repp::Invoice.new(@invoice, simplify: true)
        render_success(data: { invoice: serializer.to_json
                                                  .merge!(recipient: recipient) })
      end

      api :put, '/repp/v1/invoices/:id/cancel'
      desc 'Cancel a specific invoice'
      def cancel
        action = Actions::InvoiceCancel.new(@invoice)
        if action.call
          EisBilling::SendInvoiceStatus.send_info(invoice_number: @invoice.number,
                                                  status: 'cancelled')
        else
          handle_non_epp_errors(@invoice)
          return
        end

        serializer = Serializers::Repp::Invoice.new(@invoice, simplify: true)
        render_success(data: { invoice: serializer.to_json })
      end

      api :post, '/repp/v1/invoices/add_credit'
      desc 'Generate add credit invoice'
      def add_credit
        deposit = Deposit.new(invoice_params.merge(registrar: current_user.registrar))
        invoice = deposit.issue_prepayment_invoice
        if invoice
          serializer = Serializers::Repp::Invoice.new(invoice, simplify: true)
          render_success(data: { invoice: serializer.to_json })
        else
          handle_non_epp_errors(deposit)
        end
      end

      private

      def index_params
        params.permit(:id, :limit, :offset, :details, :q, :simple,
                      :page, :per_page,
                      q: %i[number_str_matches due_date_gteq due_date_lteq
                            account_activity_created_at_gteq
                            account_activity_created_at_lteq
                            account_activity_id_not_null
                            account_activity_id_null
                            cancelled_at_not_null
                            number_gteq number_lteq
                            total_gteq total_lteq s] + [s: []])
      end

      def search_params
        index_params.fetch(:q, {})
      end

      def invoice_params
        params.require(:invoice).permit(:id, :recipient, :amount, :description)
      end

      def limit
        index_params[:limit] || 200
      end

      def offset
        index_params[:offset] || 0
      end

      def serialized_invoices(invoices)
        return invoices.map(&:number) unless index_params[:details] == 'true'

        simple = index_params[:simple] == 'true' || false
        invoices.map { |i| Serializers::Repp::Invoice.new(i, simplify: simple).to_json }
      end
    end
  end
end
