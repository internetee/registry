FactoryGirl.define do
  factory :registrant, parent: :contact, class: Registrant do
    name 'test'
  end
end
