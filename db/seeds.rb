# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
ActiveRecord::Base.transaction do
  AdminUser.where('username': 'admin').first_or_create!(
    username: 'admin',
    email: 'admin@domain.tld',
    password: 'adminadmin',
    password_confirmation: 'adminadmin',
    identity_code: '38001085718',
    country_code: 'EE',
    roles: ['admin']
  )
  # Required for creating registrar
  Setting.where('var': 'registry_vat_prc').first_or_create(
    value: '0.2'
  )
  # First registrar
  Registrar.where('name': 'Registrar First').first_or_create!(
    name: 'Registrar First',
    reg_no: '90010019',
    accounting_customer_code: '1234',
    language: 'EE',
    reference_no: '11',
    #    vat_rate: '0.2',
    vat_no: 'EE101286464',
    address_country_code: 'EE',
    address_state: 'Harjumaa',
    address_city: 'Tallinn',
    address_street: 'Tänav 1',
    address_zip: '1234546',
    email: 'registrar@first.tld',
    code: 'REG1'
  )

#  registrar.accounts.create!(account_type: Account::CASH, currency: 'EUR')

#  ApiUser.create!(
#    username: 'api_first',
#    password: 'api_first',
#    identity_code: '38001085718',
#    active: true,
#    registrar: registrar,
#    roles: ['epp']
#  )



#  ZonefileSetting.create!(
#    origin: 'tld',
#    ttl: 43200,
#    refresh: 3600,
#    retry: 900,
#    expire: 1209600,
#    minimum_ttl: 3600,
#    email: 'admin.domain.tld',
#    master_nameserver: 'ns.tld'
#  )
end
