Fabricator(:registrar) do
  name { sequence(:name) { |i| "Registrar #{i}" } }
  reg_no { sequence(:reg_no) { |i| "123#{i}" } }
  address 'Street 999, Town, County, Postal'
  email 'info@registrar1.ee'
  country_code 'EE'
end

Fabricator(:registrar1, from: :registrar) do
  name 'registrar1'
  reg_no '111'
  address 'Street 111, Town, County, Postal'
  email 'info@registrar1.ee'
end

Fabricator(:registrar2, from: :registrar) do
  name 'registrar2'
  reg_no '222'
  address 'Street 222, Town, County, Postal'
  email 'info@registrar2.ee'
end
