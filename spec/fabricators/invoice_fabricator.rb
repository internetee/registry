Fabricator(:invoice) do
  buyer_name 'Registrar 1'
  currency { 'EUR' }
  due_date { Time.zone.now.to_date + 1.day }
  invoice_type 'DEB'
  seller_iban { '123' }
  seller_name { 'EIS' }
  seller_city { 'Tallinn' }
  seller_street { 'Paldiski mnt. 123' }
  invoice_items(count: 2)
  vat_prc 0.2
end
