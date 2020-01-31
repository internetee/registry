module PaymentOrders
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

    def compose_or_find_transaction
      transaction = BankTransaction.find_by(base_transaction_params)

      # Transaction already autobinded (possibly) invalid invoice
      if transaction.binded?
        Rails.logger.info("Transaction #{transaction.id} is already binded")
        Rails.logger.info('Creating new BankTransaction record.')

        transaction = new_base_transaction
      end

      transaction
    end

    def new_base_transaction
      BankTransaction.new(base_transaction_params)
    end

    def base_transaction_params
      {
        description: invoice.order,
        currency: invoice.currency,
        iban: invoice.seller_iban,
      }
    end

    def form_url
      ENV["payments_#{type}_url"]
    end
  end
end
