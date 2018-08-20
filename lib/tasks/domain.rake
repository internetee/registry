namespace :domain do
  desc 'Discard domains'
  task discard: :environment do
    Domain.discard_domains do |domain|
      puts "#{domain} is discarded"
    end
  end
end