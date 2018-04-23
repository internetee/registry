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

    def form_url
      ENV["payments_#{type}_url"]
    end
  end
end
