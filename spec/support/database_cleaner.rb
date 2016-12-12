RSpec.configure do |config|
  db_connection_names = %i(test whois_test api_log_test registrant_write_test)

  config.before :suite do
    DatabaseCleaner.strategy = :truncation

    db_connection_names.each do |connection_name|
      ActiveRecord::Base.establish_connection(connection_name)
      DatabaseCleaner[:active_record, connection: connection_name].strategy = :truncation
    end
  end

  config.before :example do |example|
    if example.metadata[:db]
      db_connection_names.each do |connection_name|
        ActiveRecord::Base.establish_connection(connection_name)
        DatabaseCleaner[:active_record, connection: connection_name].start
      end
    end
  end

  config.after :example do |example|
    if example.metadata[:db]
      db_connection_names.each do |connection_name|
        ActiveRecord::Base.establish_connection(connection_name)
        DatabaseCleaner[:active_record, connection: connection_name].clean
      end
    end
  end
end
