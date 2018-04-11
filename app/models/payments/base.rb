module Payments
  class Base
    include ActionView::Helpers::NumberHelper

    attr_reader :type,
                :invoice,
                :return_url,
                :response_url,
                :response

    def initialize(type, invoice, opts = {})
      @type         = type
      @invoice      = invoice
      @return_url   = opts[:return_url]
      @response_url = opts[:response_url]
      @response     = opts[:response]
    end

    def create_transaction
      transaction = BankTransaction.where(description: invoice.order).first_or_initialize(
        reference_no: invoice.reference_no,
        currency: invoice.currency,
        iban: invoice.seller_iban
      )

      transaction.save!
    end

    def complete_transaction
      fail NotImplementedError
    end

    def settled_payment?
      fail NotImplementedError
    end

    def form_fields
      fail NotImplementedError
    end

    def form_url
      ENV["#{type}_payment_url"]
    end

    def valid_response?
      fail NotImplementedError
    end
  end
end
