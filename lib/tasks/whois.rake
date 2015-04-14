namespace :whois do
  desc 'Delete whois database data and import all from Registry (fast)'
  task reset: :environment do
    start = Time.zone.now.to_f
    print "-----> Reset whois database and sync..."
    domains = Domain.pluck(:name, :whois_body)
    Whois::Domain.delete_all
    Whois::Domain.import([:name, :whois_body], domains)
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Sync whois database without reset (slow)'
  task sync: :environment do
    start = Time.zone.now.to_f
    print "-----> Sync whois database..."
    Domain.select(:id, :name, :whois_body).find_each(batch_size: 100000).with_index do |d, index|
      d.update_whois_server
      print '.' if index % 100 == 0
    end
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Regenerate whois_body at Registry master database (slow)'
  task generate: :environment do
    start = Time.zone.now.to_f
    print "-----> Update Registry records..."
    Domain.included.find_each(batch_size: 100000).with_index do |d, index|
      d.update_columns(whois_body: d.update_whois_body)
      print '.' if index % 100 == 0
    end
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end
end
