namespace :domain do
  task discard: :environment do
    Domain.discard_domains
  end
end
