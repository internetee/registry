namespace :whois do
  desc 'Regenerate whois records at Registry master database (slow)'
  task regenerate: :environment do
    start = Time.zone.now.to_f
    print "-----> Regenerate whois records at Registry master database..."
    Domain.included.find_each(batch_size: 50000).with_index do |d, index|
      d.update_whois_record
      print '.' if index % 100 == 0
    end
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Delete whois database data and sync with Registry master database (fast)'
  task export: :environment do
    start = Time.zone.now.to_f
    print "-----> Delete whois database data and sync with Registry master database..."
    whois_records = WhoisRecord.pluck(:name, :body, :json)
    Whois::Record.delete_all
    Whois::Record.import([:name, :body, :json], whois_records)
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
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

    desc 'Force whois schema into exsisting whois database'
    task force_load: [:environment] do
      whois_db = "whois_#{Rails.env}"
      begin
        puts "\n------------------------ #{whois_db} schema loading ------------------------------\n"
        ActiveRecord::Base.clear_all_connections!
        ActiveRecord::Base.establish_connection(whois_db.to_sym)
        load("#{Rails.root}/db/#{schema_file(whois_db)}")
      rescue => e
        puts "\n#{e}"
      end
    end
  end
end
