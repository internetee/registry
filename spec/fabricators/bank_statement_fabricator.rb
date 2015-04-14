Fabricator(:bank_statement) do
  bank_code { '767' }
  iban { 'EE557700771000598731' }
  queried_at { Time.zone.now }
  bank_transactions(count: 2)
end
