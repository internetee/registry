FactoryBot.define do
  factory :registrant, parent: :contact, class: Registrant do
    name 'test'

    factory :registrant_private_entity, class: Registrant, parent: :contact_private_entity
    factory :registrant_legal_entity, class: Registrant, parent: :contact_legal_entity
    factory :registrant_with_address, class: Registrant, parent: :contact_with_address
    factory :registrant_without_address, class: Registrant, parent: :contact_without_address
  end
end
