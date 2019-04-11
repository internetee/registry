class Registrar
  module Invoices
    class DeliveryController < BaseController
      include Deliverable

      private

      def redirect_url
        registrar_invoice_path(@invoice)
      end
    end
  end
end