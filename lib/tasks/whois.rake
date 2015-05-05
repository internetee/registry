namespace :whois do
  desc 'Regenerate Registry whois_records table and sync with whois server (slower)'
  task regenerate: :environment do
    start = Time.zone.now.to_f

    @i = 0
    print "-----> Regenerate Registry whois_records table and sync with whois server..."
    ActiveRecord::Base.uncached do
      puts "\n#{@i}"
      Domain.included.find_in_batches(batch_size: 10000) do |batch|
        batch.map(&:update_whois_record)
        puts(@i += 10000)
        GC.start
      end
    end
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  # desc 'Delete whois database data and import from Registry master database (faster)'
  # task export: :environment do
    # start = Time.zone.now.to_f
    # print "-----> Delete whois database data and import from Registry whois_records table..."
    # whois_records = WhoisRecord.pluck(:name, :body, :json)
    # Whois::Record.delete_all
    # Whois::Record.import([:name, :body, :json], whois_records)
    # puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  # end

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
