module EisBilling
  class LhvConnectTransactionsController < EisBilling::BaseController
    def create
      params['_json'].each do |incoming_transaction|
        process_transactions(incoming_transaction)
      end

      render status: :ok, json: { message: 'RECEIVED', params: params }
    end

    private

    def process_transactions(incoming_transaction)
      logger.info 'Got incoming transactions'
      logger.info incoming_transaction

      bank_statement = BankStatement.new(bank_code: Setting.registry_bank_code,
                                         iban: Setting.registry_iban)

      ActiveRecord::Base.transaction do
        bank_statement.save!
        transaction = create_transaction(incoming_transaction: incoming_transaction, bank_statement: bank_statement)

        next if transaction.registrar.blank?

        create_invoice_if_missing(transaction) unless transaction.non_canceled?
      end
    end

    def create_invoice_if_missing(transaction)
      Invoice.create_from_transaction!(transaction) unless transaction.autobindable?
      transaction.autobind_invoice
    end

    def create_transaction(incoming_transaction:, bank_statement:)
      transaction_attributes = { sum: incoming_transaction['amount'],
                                 currency: incoming_transaction['currency'],
                                 paid_at: incoming_transaction['date'],
                                 reference_no: incoming_transaction['payment_reference_number'],
                                 description: incoming_transaction['payment_description'] }

      bank_statement.bank_transactions.create!(transaction_attributes)
    end
  end
end
