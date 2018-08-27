namespace :domain do
  desc 'Discard domains'
  task discard: :environment do
    domain_count = 0

    Domain.discard_domains do |domain|
      puts "#{domain} is discarded"
      domain_count = domain_count + 1
    end

    puts "Discarded total: #{domain_count}"
  end
end