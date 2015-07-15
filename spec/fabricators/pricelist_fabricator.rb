Fabricator(:pricelist) do
  valid_from 1.year.ago
  valid_to 1.year.since
  category 'ee'
  duration '1year'
  operation_category 'create'
  price 10
end
