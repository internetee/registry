FactoryBot.define do
  factory :registrar do
    sequence(:name) { |n| "test#{n}" }
    sequence(:code) { |n| "test#{n}" }
    sequence(:reg_no) { |n| "test#{n}" }
    street 'test'
    city 'test'
    state 'test'
    zip 'test'
    email 'test@test.com'
    country_code 'EE'
    accounting_customer_code 'test'
    vat_rate 5

    factory :registrar_with_unlimited_balance do
      after :create do |registrar|
        create(:account, registrar: registrar, balance: 1_000_000)
      end
    end

    factory :registrar_with_zero_balance do
      after :create do |registrar|
        create(:account, registrar: registrar, balance: 0)
      end
    end
  end
end
