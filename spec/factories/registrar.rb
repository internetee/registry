FactoryBot.define do
  factory :registrar do
    sequence(:name) { |n| "test#{n}" }
    sequence(:code) { |n| "test#{n}" }
    sequence(:reg_no) { |n| "test#{n}" }
    email 'test@test.com'
    address_street 'test'
    address_city 'test'
    address_country_code 'US'
    accounting_customer_code 'test'
    language 'en'
    sequence(:reference_no) { |n| "1234#{n}" }

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
