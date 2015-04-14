Fabricator(:registrar) do
  name { sequence(:name) { |i| "Registrar #{i}" } }
  reg_no { sequence(:reg_no) { |i| "123#{i}" } }
  street 'Street 999'
  city 'Town'
  state 'County'
  zip 'Postal'
  email 'info@registrar1.ee'
  country_code 'EE'
  reference_no { sequence(:reference_no) { |i| "RF#{i}" } }
  accounts(count: 1)
end

Fabricator(:registrar1, from: :registrar) do
  name 'registrar1'
  reg_no '111'
  street 'Street 111'
  city 'Town'
  state 'County'
  zip 'Postal'
  email 'info@registrar1.ee'
end

Fabricator(:registrar2, from: :registrar) do
  name 'registrar2'
  reg_no '222'
  street 'Street 222'
  city 'Town'
  state 'County'
  zip 'Postal'
  email 'info@registrar2.ee'
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
  url 'www.internet.ee'
end
