Fabricator(:pricelist) do
  active_from 1.year.ago
  active_until 1.year.since
  category '.ee'
end
