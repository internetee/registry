module EisBilling
  class LhvConnectTransactionsController < EisBilling::BaseController
    def create
      params["_json"].each do |incoming_transaction|
        process_transactions(incoming_transaction["table"])
      end

      render status: 200, json: { message: 'RECEIVED', status: :ok, params: params }
    end

    private

    def process_transactions(incoming_transaction)
      logger.info 'Got incoming transactions'
      logger.info incoming_transaction

      bank_statement = BankStatement.new(bank_code: Setting.registry_bank_code,
                                          iban: Setting.registry_iban)

      ActiveRecord::Base.transaction do
        bank_statement.save!

        transaction_attributes = { sum: incoming_transaction["amount"],
                                    currency: incoming_transaction["currency"],
                                    paid_at: incoming_transaction["date"],
                                    reference_no: incoming_transaction["payment_reference_number"],
                                    description: incoming_transaction["payment_description"] }
        transaction = bank_statement.bank_transactions.create!(transaction_attributes)

        next if transaction.registrar.blank?

        unless transaction.non_canceled?
          Invoice.create_from_transaction!(transaction) unless transaction.autobindable?
          transaction.autobind_invoice
        end
      end
    end
  end
end
