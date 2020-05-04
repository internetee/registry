module Concerns
  module Invoice
    module BookKeeping
      extend ActiveSupport::Concern

      def as_directo_json
        invoice = ActiveSupport::JSON.decode(ActiveSupport::JSON.encode(self))
        invoice['customer_code'] = buyer.accounting_customer_code
        invoice['issue_date'] = issue_date.strftime('%Y-%m-%d')
        invoice['transaction_date'] = account_activity
                                      .bank_transaction&.paid_at&.strftime('%Y-%m-%d')
        invoice['language'] = buyer.language == 'en' ? 'ENG' : ''
        invoice['invoice_lines'] = compose_directo_product

        invoice
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
