namespace :db do
  def databases
    @db ||= ["api_log_#{Rails.env}", "whois_#{Rails.env}", "#{Rails.env}"]
  end

  def schema_file(db)
    case db
    when databases.first
      'api_log_schema.rb'
    when databases.second
      'whois_schema.rb'
    when databases.third
      'schema.rb'
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
      databases.each do |name|
        begin
          conf = ActiveRecord::Base.configurations
          ActiveRecord::Base.clear_all_connections!
          ActiveRecord::Base.connection.create_database(conf[name]['database'], conf[name])
        rescue => e
          puts "\n#{e}"
        end
      end
    end

    namespace :schema do
      desc 'Schema load for all databases: registry, api_log and whois'
      task load: [:environment] do
        databases.each do |name|
          begin
            puts "\n---------------------------- #{name} ----------------------------------------\n"
            ActiveRecord::Base.establish_connection(name)
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
        databases.each do |name|
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
