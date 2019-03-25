namespace :whois do
  desc 'Regenerate Registry whois_records table and sync with whois server (slower)'
  task regenerate: :environment do
    start = Time.zone.now.to_f

    print "-----> Regenerate Registry whois_records table and sync with whois server..."
    ActiveRecord::Base.uncached do

      # Must be on top
      print "\n-----> Update whois_records for auctions"
      Auction.pluck('DISTINCT domain').each do |domain|
        pending_auction = Auction.pending(domain)

        if pending_auction
          Whois::Record.transaction do
            whois_record = Whois::Record.find_or_create_by!(name: domain)
            whois_record.update_from_auction(pending_auction)
          end
        else
          Whois::Record.find_by(name: domain)&.destroy!
        end
      end

      print "\n-----> Update domains whois_records"
      Domain.find_in_batches.each do |group|
        UpdateWhoisRecordJob.enqueue group.map(&:name), 'domain'
      end

      print "\n-----> Update blocked domains whois_records"
      BlockedDomain.find_in_batches.each do |group|
        UpdateWhoisRecordJob.enqueue group.map(&:name), 'blocked'
      end

      print "\n-----> Update reserved domains whois_records"
      ReservedDomain.find_in_batches.each do |group|
        UpdateWhoisRecordJob.enqueue group.map(&:name), 'reserved'
      end
    end
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Create whois database'
  task create: [:environment] do
    whois_db = "whois_#{Rails.env}"
    begin
      puts "\n------------------------ Create #{whois_db} ---------------------------------------\n"
      ActiveRecord::Base.clear_all_connections!
      conf = ActiveRecord::Base.configurations

      ActiveRecord::Base.connection.create_database(conf[whois_db]['database'].to_sym, conf[whois_db])
    rescue => e
      puts "\n#{e}"
    end
  end

  desc 'Drop whois database'
  task drop: [:environment] do
    # just in case we allow only drop test, comment it out only for temp
    if Rails.env.test?
      whois_db = "whois_#{Rails.env}"

      begin
        puts "\n------------------------ #{whois_db} drop ------------------------------\n"
        ActiveRecord::Base.clear_all_connections!
        ActiveRecord::Base.establish_connection(whois_db.to_sym)

        conf = ActiveRecord::Base.configurations
        if ActiveRecord::Tasks::DatabaseTasks.drop(conf[whois_db])
          puts "#{conf[whois_db]['database']} dropped"
        else
          puts "Didn't find database #{whois_db}, no drop"
        end
      rescue => e
        puts "\n#{e}"
      end
    else
      puts 'Only for test'
    end
  end

  namespace :schema do
    desc 'Load whois schema into empty whois database'
    task load: [:environment] do
      whois_db = "whois_#{Rails.env}"
      begin
        puts "\n------------------------ #{whois_db} schema loading ------------------------------\n"
        ActiveRecord::Base.clear_all_connections!
        ActiveRecord::Base.establish_connection(whois_db.to_sym)
        if ActiveRecord::Base.connection.table_exists?('schema_migrations')
          puts 'Found tables, skip schema load!'
        else
          load("#{Rails.root}/db/#{schema_file(whois_db)}")
        end
      rescue => e
        puts "\n#{e}"
      end
    end
  end
end
