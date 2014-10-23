# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Country.where(name: 'Estonia', iso: 'EE').first_or_create!
Country.where(name: 'Latvia', iso: 'LV').first_or_create!

zone = Registrar.where(
  name: 'Zonedata AS',
  reg_no: '10300220',
  address: 'Pärnu mnt 2, Tallinna linn, Harju maakond, 11415',
  country: Country.first
).first_or_create

EppUser.where(
  username: 'zone',
  password: 'ghyt9e4fu',
  active: true,
  registrar: zone
).first_or_create

elkdata = Registrar.where(
  name: 'Elkservers OÜ',
  reg_no: '10529229',
  address: 'Vabaduse pst 32, 11316 Tallinn',
  country: Country.first
).first_or_create

EppUser.where(
  username: 'elkdata',
  password: '8932iods',
  active: true,
  registrar: elkdata
).first_or_create

User.where(
  username: 'gitlab',
  password: '12345',
  email: 'info@gitlab.eu',
  admin: true,
  identity_code: '37810013855',
  country: Country.where(name: 'Estonia').first
).first_or_create

User.where(
  username: 'zone',
  password: '54321',
  email: 'zone-info@example.ee',
  admin: false,
  identity_code: '37810010085',
  registrar_id: zone.id,
  country: Country.where(name: 'Estonia').first
).first_or_create

User.where(
  username: 'elkdata',
  password: '32154',
  email: 'elk-info@example.ee',
  admin: false,
  identity_code: '37810010727',
  registrar_id: elkdata.id,
  country: Country.where(name: 'Estonia').first
).first_or_create

Setting.ds_algorithm = 2
Setting.ds_data_allowed = true
Setting.ds_data_with_key_allowed = true
Setting.key_data_allowed = true

Setting.dnskeys_min_count = 0
Setting.dnskeys_max_count = 9
Setting.ns_min_count = 2
Setting.ns_max_count = 11

Setting.transfer_wait_time = 0
