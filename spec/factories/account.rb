FactoryBot.define do
  factory :account do
    account_type Account::CASH
    balance 1
    currency 'EUR'
    registrar
  end
end
