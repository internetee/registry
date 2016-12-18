FactoryGirl.define do
  factory :pricelist do
    valid_from Time.zone.parse('05.07.2010')
    valid_to Time.zone.parse('05.07.2010')
    category 'com'
    duration '1year'
    operation_category 'create'
    price 1.to_money
  end
end
