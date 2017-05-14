desc 'Bootstraps production-like environment'
task :bootstrap do
  AdminUser.create!(
      username: 'demo',
      email: 'demo@domain.tld',
      password: 'demodemo',
      password_confirmation: 'demodemo',
      country_code: 'US',
      roles: ['admin']
  )
end
