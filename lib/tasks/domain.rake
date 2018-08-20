namespace :domain do
  desc 'Discard domains'
  task discard: :environment do
    Domain.discard_domains
  end
end
