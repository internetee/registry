FactoryBot.define do
  factory :invoice do
    buyer_name 'Registrar 1'
    currency { 'EUR' }
    due_date { Time.zone.now.to_date + 1.day }
    seller_iban { '123' }
    seller_name { 'EIS' }
    seller_city { 'Tallinn' }
    seller_street { 'Paldiski mnt. 123' }
    vat_prc 0.2
    buyer { FactoryBot.create(:registrar) }

    after :build do |invoice|
      invoice.invoice_items << FactoryBot.create_pair(:invoice_item)
    end
  end
end
