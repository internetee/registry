namespace :db do
  def other_databases
    @db ||= ["api_log_#{Rails.env}", "whois_#{Rails.env}"]
  end

  def schema_file(db)
    case db
    when "api_log_#{Rails.env}"
      'api_log_schema.rb'
    when "whois_#{Rails.env}"
      'whois_schema.rb'
    end
  end

  namespace :all do
    desc 'Create all databases: registry, api_log and whois'
    task setup: [:environment] do
      Rake::Task['db:all:create'].invoke
      Rake::Task['db:all:schema:load'].invoke
      Rake::Task['db:seed'].invoke
    end

    desc 'Create all databases: registry, api_log and whois'
    task create: [:environment] do
      puts "\n---------------------------- Create main database ----------------------------------------\n"
      Rake::Task['db:create'].invoke

      other_databases.each do |name|
        begin
          puts "\n---------------------------- Create #{name} ----------------------------------------\n"
          ActiveRecord::Base.clear_all_connections!
          conf = ActiveRecord::Base.configurations
          ActiveRecord::Base.connection.create_database(conf[name]['database'].to_sym, conf[name])
        rescue => e
          puts "\n#{e}"
        end
      end
    end

    desc 'Drop all databaseses: registry, api_log and whois'
    task drop: [:environment] do
      # just in case we allow only drop test, comment it out please for temp
      return unless Rails.env.test?

      puts "\n---------------------------- Drop main database ----------------------------------------\n"
      Rake::Task['db:drop'].invoke

      other_databases.each do |name|
        begin
          puts "\n---------------------------- #{name} dropped ----------------------------------------\n"
          ActiveRecord::Base.clear_all_connections!
          ActiveRecord::Base.establish_connection(name.to_sym)

          conf = ActiveRecord::Base.configurations
          if ActiveRecord::Tasks::DatabaseTasks.drop(conf[name])
            puts "#{conf[name]['database']} dropped"
          else
            puts "Didn't find database #{name}, no drop"
          end
        rescue => e
          puts "\n#{e}"
        end
      end
    end

    namespace :schema do
      desc 'Schema load for all databases: registry, api_log and whois'
      task load: [:environment] do
        puts "\n---------------------------- Main schema load ----------------------------------------\n"
        Rake::Task['db:schema:load'].invoke

        other_databases.each do |name|
          begin
            puts "\n---------------------------- #{name} schema loaded ----------------------------------------\n"
            ActiveRecord::Base.clear_all_connections!
            ActiveRecord::Base.establish_connection(name.to_sym)
            if ActiveRecord::Base.connection.table_exists?('schema_migrations')
              puts 'Found tables, skip schema load!'
            else
              load("#{Rails.root}/db/#{schema_file(name)}")
            end
          rescue => e
            puts "\n#{e}"
          end
        end
      end

      desc 'Schema load for all databases: registry, api_log and whois'
      task dump: [:environment] do
        puts "\n---------------------------- Main schema load ----------------------------------------\n"
        Rake::Task['db:schema:dump'].invoke

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
