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
  country_code: 'EE'
).first_or_create!

ApiUser.where(
  username: 'registrar1',
  password: 'test1',
  active: true,
  registrar: registrar1
).first_or_create!

registrar2 = Registrar.where(
  name: 'Registrar Second AS',
  reg_no: '10529229',
  street: 'Vabaduse pst 32',
  city: 'Tallinn',
  state: 'Harju maakond',
  zip: '11315',
  email: 'registrar2@example.com',
  country_code: 'EE'
).first_or_create!

ApiUser.where(
  username: 'registrar2',
  password: 'test2',
  active: true,
  registrar: registrar2
).first_or_create!

AdminUser.where(
  username: 'user1',
  password: 'test1',
  email: 'user1@example.ee',
  identity_code: '37810013855',
  country_code: 'EE'
).first_or_create!

AdminUser.where(
  username: 'user2',
  password: 'test2',
  email: 'user2@example.ee',
  identity_code: '37810010085',
  country_code: 'EE'
).first_or_create!

AdminUser.where(
  username: 'user3',
  password: 'test3',
  email: 'user3@example.ee',
  identity_code: '37810010727',
  country_code: 'EE'
).first_or_create!

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

AdminUser.update_all(roles: ['admin'])
