namespace :whois do
  desc 'Regenerate Registry records and sync whois database'
  task sync_all: :environment do

  end

  desc 'Regenerate whois records at Registry master database'
  task generate: :environment do
    start = Time.zone.now.to_f
    print "-----> Update Registry whois records..."
    Domain.included.find_each(batch_size: 100000).with_index do |d, index|
      d.update_columns(whois_body: d.update_whois_body)
      print '.' if index % 100 == 0
    end
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Sync whois database'
  task sync: :environment do
    start = Time.zone.now.to_f
    print "-----> Sync whois database..."
    Domain.select(:id, :name, :whois_body).find_each(batch_size: 100000).with_index do |d, index|
      d.update_whois_server
      print '.' if index % 100 == 0
    end
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end
end
