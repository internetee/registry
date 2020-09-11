namespace :invoices do
  task process_payments: :environment do
    registry_bank_account_iban = Setting.registry_iban

    keystore = OpenSSL::PKCS12.new(File.read(ENV['lhv_p12_keystore']), ENV['lhv_keystore_password'])
    key = keystore.key
    cert = keystore.certificate

    api = Lhv::ConnectApi.new
    api.cert = cert
    api.key = key
    api.ca_file = ENV['lhv_ca_file']
    api.dev_mode = ENV['lhv_dev_mode'] == 'true'

    incoming_transactions = []

    api.credit_debit_notification_messages.each do |message|
      next unless message.bank_account_iban == registry_bank_account_iban

      message.credit_transactions.each do |credit_transaction|
        incoming_transactions << credit_transaction
      end
    end

    if incoming_transactions.any?
      bank_statement = BankStatement.new(bank_code: Setting.registry_bank_code,
                                         iban: Setting.registry_iban)

      ActiveRecord::Base.transaction do
        bank_statement.save!

        incoming_transactions.each do |incoming_transaction|
          transaction_attributes = { sum: incoming_transaction.amount,
                                     currency: incoming_transaction.currency,
                                     paid_at: incoming_transaction.date,
                                     reference_no: incoming_transaction.payment_reference_number,
                                     description: incoming_transaction.payment_description }
          transaction = bank_statement.bank_transactions.create!(transaction_attributes)
          Invoice.create_from_transaction!(transaction) unless transaction.autobindable?

          transaction.autobind_invoice
        end
      end
    end

    puts "Transactions processed: #{incoming_transactions.size}"
  end
end
