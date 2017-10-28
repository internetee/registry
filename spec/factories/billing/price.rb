FactoryBot.define do
  factory :price, class: Billing::Price do
    price Money.from_amount(1)
    valid_from Time.zone.parse('05.07.2010')
    valid_to Time.zone.parse('05.07.2010')
    duration '1 year'
    operation_category Billing::Price.operation_categories.first
    zone

    factory :effective_price do
      expire_time { Time.zone.now + 1.day }
    end

    factory :expired_price do
      expire_time { Time.zone.now - 1.day }
    end
  end
end
