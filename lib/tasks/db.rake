Rake::Task["db:schema:load"].clear

Rake::Task["db:migrate"].enhance do
  if ActiveRecord::Base.schema_format == :sql
    Rake::Task["db:schema:dump"].invoke
  end
end

Rake::Task["db:rollback"].enhance do
  if ActiveRecord::Base.schema_format == :sql
    Rake::Task["db:schema:dump"].invoke
  end
end

Rake::Task["db:schema:dump"].enhance do
  if ActiveRecord::Base.schema_format == :sql
    File.rename('db/schema.rb', 'db/schema-read-only.rb')
    Rake::Task["db:structure:dump"].invoke # for users who do manually db:schema:dump
  end
end

namespace :db do
  namespace :schema do
    task load: [:environment, :load_config] do
      puts 'Only rake db:structure:load is supported and invoked. ' \
           'Otherwise zonefile generation does not work nor que.'
      Rake::Task["db:structure:load"].invoke
    end
  end

  def databases
    @db ||= [Rails.env, "api_log_#{Rails.env}", "whois_#{Rails.env}"]
  end

  def other_databases
    @other_dbs ||= ["api_log_#{Rails.env}", "whois_#{Rails.env}"]
  end

  def schema_file(db)
    case db
    when Rails.env
      'structure.sql' # just in case
    when "api_log_#{Rails.env}"
      'api_log_schema.rb'
    when "whois_#{Rails.env}"
      'whois_schema.rb'
    end
  end

  namespace :all do
    desc 'Create all databases: registry, api_log and whois'
    task setup: [:environment, :load_config] do
      Rake::Task['db:all:create'].invoke
      Rake::Task['db:all:schema:load'].invoke

      ActiveRecord::Base.clear_all_connections!
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)

      puts "\n---------------------------- Import seed ----------------------------------------\n"
      Rake::Task['db:seed'].invoke
      puts "\n  All done!\n\n"
    end

    desc 'Create all databases: registry, api_log and whois'
    task create: [:environment, :load_config] do
      databases.each do |name|
        begin
          puts "\n------------------------ Create #{name} ---------------------------------------\n"
          ActiveRecord::Base.clear_all_connections!
          conf = ActiveRecord::Base.configurations
          
          if name == Rails.env
            ActiveRecord::Tasks::DatabaseTasks.create_current
          else
            ActiveRecord::Base.connection.create_database(conf[name]['database'].to_sym, conf[name])
          end
        rescue => e
          puts "\n#{e}"
        end
      end
    end

    desc 'Drop all databaseses: registry, api_log and whois'
    task drop: [:environment, :load_config] do
      # just in case we allow only drop test, comment it out only for temp
      return unless Rails.env.test?

      databases.each do |name|
        begin
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
      task load: [:environment, :load_config] do
        puts "\n------------------------ #{Rails.env} structure loading -----------------------------\n"
        Rake::Task['db:structure:load'].invoke

        other_databases.each do |name|
          begin
            puts "\n------------------------ #{name} schema loading -----------------------------\n"
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

      desc 'Schema dump for all databases: registry, api_log and whois'
      task dump: [:environment, :load_config] do
        puts "\n---------------------------- #{Rails.env} structure and schema dump--------------\n"
        Rake::Task['db:schema:dump'].invoke # dumps both schema and structure

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
      # alias names
      namespace :structure do
        desc '(alias) Schema dump for all databases: registry, api_log and whois'
        task :dump do
          Rake::Task['db:all:schema:dump'].invoke
        end
        desc '(alias) Schema load for all databases: registry, api_log and whois'
        task :load do
          Rake::Task['db:all:schema:load'].invoke
        end
      end
    end
  end
end
