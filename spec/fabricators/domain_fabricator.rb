Fabricator(:domain) do
  name { "#{Faker::Internet.domain_word}.ee" }
  period 1
end
