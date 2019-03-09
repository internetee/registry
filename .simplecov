SimpleCov.start 'rails' do
  add_filter '/app/models/legacy/'
  add_filter '/app/models/version/'
  add_filter '/lib/action_controller/'
  add_filter '/lib/core_ext/'
  add_filter '/lib/daemons/'
  add_filter '/lib/gem_ext/'
end