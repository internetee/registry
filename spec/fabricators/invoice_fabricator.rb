Fabricator(:invoice) do
  invoice_type 'DEB'
  due_date { Time.zone.now.to_date + 1.day }
  payment_term { 'Prepayment' }
  currency { 'EUR' }
  description { 'Invoice no. 1' }
  description { 'Invoice no. 1' }
  domain
end
