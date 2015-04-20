Fabricator(:account) do
  account_type { Account::CASH }
  balance 0.0
  currency 'EUR'
  # account_activities(count: 2)
end
