FactoryGirl.define do
  factory :contact do
    name 'test'
    sequence(:code) { |n| "test#{n}" }
    phone '+123.456789'
    email 'test@test.com'
    street 'test'
    city 'test'
    zip 12345
    country_code 'EE'
    ident '37605030299'
    ident_type 'priv'
    ident_country_code 'EE'
    registrar

    factory :contact_private_entity do
      ident_type 'priv'
    end

    factory :contact_legal_entity do
      ident_type 'org'
      ident '12345678' # valid reg no for .ee
    end
  end
end
