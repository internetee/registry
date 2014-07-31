Fabricator(:domain) do
  name { "#{Faker::Internet.domain_word}.ee" }
  period 1
  owner_contact(fabricator: :contact)
end
