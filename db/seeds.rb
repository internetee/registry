# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

registrar1 = Registrar.where(
  name: 'Registrar First AS',
  reg_no: '10300220',
  street: 'Pärnu mnt 2',
  city: 'Tallinn',
  state: 'Harju maakond',
  zip: '11415',
  email: 'registrar1@example.com',
  country_code: 'EE',
  code: 'REG1'
).first_or_create!

@api_user1 = ApiUser.where(
  username: 'registrar1',
).first_or_create!(
  password: 'password',
  identity_code: '51001091072',
  active: true,
  registrar: registrar1,
  roles: ['super']
)


registrar2 = Registrar.where(
  name: 'Registrar Second AS',
  reg_no: '10529229',
  street: 'Vabaduse pst 32',
  city: 'Tallinn',
  state: 'Harju maakond',
  zip: '11315',
  email: 'registrar2@example.com',
  country_code: 'EE',
  code: 'REG2'
).first_or_create!

@api_user2 = ApiUser.where(
  username: 'registrar2',
).first_or_create!(
  password: 'password',
  identity_code: '11412090004',
  active: true,
  registrar: registrar2,
  roles: ['super']
)


Registrar.all.each do |x|
  x.accounts.where(account_type: Account::CASH, currency: 'EUR').first_or_create!
end

admin1 = {
  username: 'user1',
  email: 'user1@example.ee',
  identity_code: '37810013855',
  country_code: 'EE'
}
admin2 = {
  username: 'user2',
  email: 'user2@example.ee',
  identity_code: '37810010085',
  country_code: 'EE'
}
admin3 = {
  username: 'user3',
  email: 'user3@example.ee',
  identity_code: '37810010727',
  country_code: 'EE'
}

[admin1, admin2, admin3].each do |at|
  admin = AdminUser.where(at)
  next if admin.present?
  admin = AdminUser.new(at.merge({ password_confirmation: 'testtest', password: 'testtest' }))
  admin.roles = ['admin']
  admin.save
end

ZonefileSetting.where({
  origin: 'ee',
  ttl: 43200,
  refresh: 3600,
  retry: 900,
  expire: 1209600,
  minimum_ttl: 3600,
  email: 'hostmaster.eestiinternet.ee',
  master_nameserver: 'ns.tld.ee'
}).first_or_create!

ZonefileSetting.where({
  origin: 'pri.ee',
  ttl: 43200,
  refresh: 3600,
  retry: 900,
  expire: 1209600,
  minimum_ttl: 3600,
  email: 'hostmaster.eestiinternet.ee',
  master_nameserver: 'ns.tld.ee'
}).first_or_create!

# Registrar.where(
#   name: 'EIS',
#   reg_no: '90010019',
#   phone: '+3727271000',
#   country_code: 'EE',
#   vat_no: 'EE101286464',
#   email: 'info@internet.ee',
#   state: 'Harjumaa',
#   city: 'Tallinn',
#   street: 'Paldiski mnt 80',
#   zip: '10617',
#   url: 'www.internet.ee',
#   code: 'EIS'
# ).first_or_create!
