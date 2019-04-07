module Admin
  module Invoices
    class DeliveryController < BaseController
      include Deliverable

      private

      def redirect_url
        admin_invoice_path(@invoice)
      end
    end
  end
end