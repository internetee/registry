FactoryGirl.define do
  factory :registrant, parent: :contact, class: Registrant do
    name 'test'

    factory :registrant_private_entity, class: Registrant, parent: :contact_private_entity
    factory :registrant_legal_entity, class: Registrant, parent: :contact_legal_entity
  end
end
