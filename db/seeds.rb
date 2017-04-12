# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ActiveRecord::Base.transaction do
  registrar = Registrar.create!(
    name: 'Test',
    reg_no: '1234',
    street: 'test',
    city: 'test',
    state: 'test',
    zip: '1234',
    email: 'test@domain.tld',
    country_code: 'US',
    code: 'US1'
  )

  registrar.accounts.create!(account_type: Account::CASH, currency: 'EUR')

  ApiUser.create!(
    username: 'test',
    password: 'testtest',
    identity_code: '51001091072',
    active: true,
    registrar: registrar,
    roles: ['super']
  )

  AdminUser.create!(
    username: 'test',
    email: 'test@domain.tld',
    password: 'testtest',
    password_confirmation: 'testtest',
    country_code: 'US',
    roles: ['admin']
  )

  ZonefileSetting.create!(
    origin: 'tld',
    ttl: 43200,
    refresh: 3600,
    retry: 900,
    expire: 1209600,
    minimum_ttl: 3600,
    email: 'admin.domain.tld',
    master_nameserver: 'ns.tld'
  )
end
