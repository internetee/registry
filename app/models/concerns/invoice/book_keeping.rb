module Concerns
  module Invoice
    module BookKeeping
      extend ActiveSupport::Concern

      def as_directo_json
        inv = ActiveSupport::JSON.decode(ActiveSupport::JSON.encode(self))
        inv['customer_code'] = buyer.accounting_customer_code
        inv['issue_date'] = issue_date.strftime('%Y-%m-%d')
        inv['transaction_date'] = account_activity.bank_transaction&.paid_at&.strftime('%Y-%m-%d')
        inv['language'] = buyer.language == 'en' ? 'ENG' : ''
        inv['invoice_lines'] = compose_directo_product

        inv
      end

      def compose_directo_product
        [{ 'product_id': Setting.directo_receipt_product_name, 'description': order,
           'quantity': 1, 'price': ActionController::Base.helpers.number_with_precision(
             subtotal, precision: 2, separator: '.'
           ) }].as_json
      end
    end
  end
end
