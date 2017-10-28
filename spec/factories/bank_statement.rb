FactoryBot.define do
  factory :bank_statement do
    bank_code { '767' }
    iban { 'EE557700771000598731' }
    queried_at { Time.zone.now }

    after :build do |bank_statement|
      bank_statement.bank_transactions << FactoryBot.create_pair(:bank_transaction)
    end
  end
end
