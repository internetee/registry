FactoryBot.define do
  factory :bank_transaction do
    currency { 'EUR' }
    sum { 100.0 }
    description { 'Invoice no. 1' }
    reference_no { 'RF2405752128' }
  end
end
