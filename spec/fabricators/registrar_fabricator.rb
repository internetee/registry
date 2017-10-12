Fabricator(:registrar) do
  name { sequence(:name) { |i| "Registrar #{i}" } }
  reg_no { sequence(:reg_no) { |i| "123#{i}" } }
  street 'Street 999'
  city 'Town'
  state 'County'
  zip 'Postal'
  email 'info@registrar1.ee'
  country_code 'EE'
  code { sequence(:code) { |i| "REGISTRAR#{i}" } }
  reference_no { sequence(:reference_no) { |i| "RF#{i}" } }
end

Fabricator(:registrar_with_no_account_activities, from: :registrar) do
  accounts(count: 1) { Fabricate(:account, account_activities: []) }
end

Fabricator(:registrar1, from: :registrar) do
  name 'registrar1'
  reg_no '111'
  street 'Street 111'
  city 'Town'
  state 'County'
  zip 'Postal'
  email 'info@registrar1.ee'
  code { sequence(:code) { |i| "FIRST#{i}" } }
end

Fabricator(:registrar2, from: :registrar) do
  name 'registrar2'
  reg_no '222'
  street 'Street 222'
  city 'Town'
  state 'County'
  zip 'Postal'
  email 'info@registrar2.ee'
  code { sequence(:code) { |i| "SECOND#{i}" } }
end

Fabricator(:eis, from: :registrar) do
  name 'EIS'
  reg_no '90010019'
  phone '+372 727 1000'
  country_code 'EE'
  vat_no 'EE101286464'
  email 'info@internet.ee'
  state 'Harjumaa'
  city 'Tallinn'
  street 'Paldiski mnt 80'
  zip '10617'
  website 'www.internet.ee'
  code { sequence(:code) { |i| "EIS#{i}" } }
  accounts(count: 1) { Fabricate(:account, account_activities: []) }
end
