desc 'Bootstraps production-like environment'
task bootstrap: :environment do
  AdminUser.create!(
    username: 'admin',
    email: 'admin@domain.tld',
    password: 'adminadmin',
    password_confirmation: 'adminadmin',
    country_code: 'US',
    roles: ['admin']
  )
end
