Fabricator(:domain) do
  name { "#{Faker::Internet.domain_word}.ee" }
  valid_to Date.new(2014, 8, 7)
  period 1
  owner_contact(fabricator: :contact)
end
