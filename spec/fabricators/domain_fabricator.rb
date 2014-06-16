Fabricator(:domain) do
  name { "#{Faker::Internet.domain_word}.ee" }
end
