module EisBilling
  class LhvConnectTransactionsController < EisBilling::BaseController
    def create
      if params['_json'].nil? || params['_json'].empty?
        render json: { message: 'MISSING PARAMS' }, status: :unprocessable_entity
        return
      end

      bank_statement = BankStatement.create(bank_code: Setting.registry_bank_code,
                                            iban: Setting.registry_iban)

      params['_json'].each do |incoming_transaction|
        process_transactions(incoming_transaction, bank_statement)
      end

      render status: :ok, json: { message: 'RECEIVED', params: params }
    end

    private

    def process_transactions(incoming_transaction, bank_statement)
      logger.info 'Got incoming transactions'
      logger.info incoming_transaction

      ActiveRecord::Base.transaction do
        transaction = bank_statement.bank_transactions
                                    .create!(transaction_attributes(incoming_transaction))

        next if transaction.registrar.blank?

        create_invoice_if_missing(transaction) unless transaction.non_canceled?
      end
    end

    def create_invoice_if_missing(transaction)
      Invoice.create_from_transaction!(transaction) unless transaction.autobindable?
      transaction.autobind_invoice
    end

    def transaction_attributes(incoming_transaction)
      {
        sum: incoming_transaction['amount'],
        currency: incoming_transaction['currency'],
        paid_at: incoming_transaction['date'],
        reference_no: incoming_transaction['payment_reference_number'],
        description: incoming_transaction['payment_description'],
      }
    end
  end
end
