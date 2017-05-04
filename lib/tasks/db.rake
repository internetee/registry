namespace :db do
  namespace :setup do
    desc 'Create all databases: api_log and whois'
    task all: [:environment, :load_config] do
      Rake::Task['db:create:all'].invoke
      Rake::Task['db:structure:load'].invoke
      Rake::Task['db:schema:load:all'].invoke

      ActiveRecord::Base.clear_all_connections!
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)

      puts "\n---------------------------- Import seed ----------------------------------------\n"
      Rake::Task['db:seed'].invoke
      puts "\n  All done!\n\n"
    end
  end

  namespace :schema do
    def other_databases
      @other_dbs ||= ["api_log_#{Rails.env}", "whois_#{Rails.env}"]
    end

    def schema_file(db)
      case db
        when "api_log_#{Rails.env}"
          'api_log_schema.rb'
        when "whois_#{Rails.env}"
          'whois_schema.rb'
      end
    end

    namespace :load do
      desc 'Schema load for all databases: api_log and whois'
      task all: [:environment, :load_config] do
        other_databases.each do |name|
          begin
            puts "\n------------------------ #{name} schema loading -----------------------------\n"
            ActiveRecord::Base.clear_all_connections!
            ActiveRecord::Base.establish_connection(name.to_sym)
            load("#{Rails.root}/db/#{schema_file(name)}")
          rescue => e
            puts "\n#{e}"
          end
        end
      end
    end

    namespace :dump do
      desc 'Schema dump for all databases: api_log and whois'
      task all: [:environment, :load_config] do
        puts "\n---------------------------- #{Rails.env} schema dump--------------\n"

        other_databases.each do |name|
          begin
            puts "\n---------------------------- #{name} ----------------------------------------\n"
            filename = "#{Rails.root}/db/#{schema_file(name)}"
            File.open(filename, 'w:utf-8') do |file|
              ActiveRecord::Base.establish_connection(name)
              ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
            end
          rescue => e
            puts "\n#{e}"
          end
        end
      end
    end
  end
end
