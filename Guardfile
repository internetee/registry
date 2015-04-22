group :red_green_refactor, halt_on_fail: true do
  # start test EPP server automatically on port 8989,
  # be sure you have apache2 configured to
  # accept EPP request on port 701, what proxy to 8989.
  # port and environment is just for correct notification, all is overwritten by CLI
  # guard :rails, port: 8989, environment: 'test' do
  # # guard :rails, port: 8989, environment: 'test', CLI: 'RAILS_ENV=test unicorn -p 8989' do
    # watch('Gemfile.lock')
    # watch(%r{^(config|lib)/.*})
  # end

  guard :rspec, cmd: 'spring rspec --fail-fast', notification: false do
  # guard :rspec, cmd: 'spring rspec', notification: false do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')  { "spec" }

    # Rails example
    watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/(.*)(\.erb|\.haml|\.slim)$})          { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
    watch(%r{^app/controllers/epp/(.+)_(controller)\.rb$}) { |m| ["spec/epp/#{m[1].sub(/s$/,'')}_spec.rb"] }
    watch(%r{^app/models/epp/(.+)\.rb$})  { |m| "spec/epp/#{m[1]}_spec.rb" }
    watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
    watch('config/routes.rb')                           { "spec/routing" }
    watch('app/controllers/application_controller.rb')  { "spec/controllers" }
    watch('spec/rails_helper.rb')                       { "spec" }

    # epp tests
    watch('app/helpers/epp/contacts_helper.rb')         { 'spec/epp/contact_spec.rb' }
    watch('app/helpers/epp/domains_helper.rb')          { 'spec/epp/domain_spec.rb' }
    # Capybara features specs
    watch(%r{^app/views/(.+)/.*\.(erb|haml|slim)$})     { |m| "spec/features/#{m[1]}_spec.rb" }

    # Turnip features and steps
    watch(%r{^spec/acceptance/(.+)\.feature$})
    watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$})   { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }
  end

  # Martin does not want rubocop
  unless Socket.gethostname == 'martin'
    guard :rubocop,
      all_on_start: false,
      cli: '--display-cop-names -c .rubocop-guard.yml -f fuubar',
      notification: false do

      watch(%r{.+\.rb$})
      watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
      watch(%r{(?:.+/)?\.rubocop-guard\.yml$}) { |m| File.dirname(m[0]) }
    end
  end
end
