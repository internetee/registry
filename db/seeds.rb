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
  name: 'Zone Media OÜ',
  reg_no: '10577829',
  address: 'Lõõtsa 2, Tallinna linn, Harju maakond, 11415',
  country: Country.first
).first_or_create

EppUser.where(
  username: 'zone',
  password: 'ghyt9e4fu',
  active: true,
  registrar: zone
).first_or_create

elkdata = Registrar.where(
  name: 'Elkdata OÜ',
  reg_no: '10510593',
  address: 'Tondi 51-10, 11316 Tallinn',
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
  email: 'enquiries@gitlab.eu',
  admin: true,
  identity_code: '37810013855',
  country: Country.where(name: 'Estonia').first
).first_or_create

User.where(
  username: 'zone',
  password: '54321',
  email: 'info-info@zone.ee',
  admin: false,
  identity_code: '37810010085',
  registrar_id: zone.id,
  country: Country.where(name: 'Estonia').first
).first_or_create

User.where(
  username: 'elkdata',
  password: '32154',
  email: 'info-info@elkdata.ee',
  admin: false,
  identity_code: '37810010727',
  registrar_id: elkdata.id,
  country: Country.where(name: 'Estonia').first
).first_or_create

sg = SettingGroup.where(code: 'domain_validation').first_or_create

s_1 = Setting.where(code: 'ns_min_count').first_or_create
s_1.value = 1

s_2 = Setting.where(code: 'ns_max_count').first_or_create
s_2.value = 13

s_3 = Setting.where(code: 'dnskeys_min_count').first_or_create
s_3.value = 0

s_4 = Setting.where(code: 'dnskeys_max_count').first_or_create
s_4.value = 9

sg.settings = [s_1, s_2, s_3, s_4]
sg.save

sg = SettingGroup.where(code: 'domain_general').first_or_create

s_1 = Setting.where(code: 'transfer_wait_time').first_or_create
s_1.value = 0

sg.settings = [s_1]
sg.save
