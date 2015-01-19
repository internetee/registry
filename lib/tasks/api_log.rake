namespace :api_log do
  namespace :test do
    namespace :schema do
      # desc 'Dump additional database schema'
      task dump: [:environment] do
        filename = "#{Rails.root}/db/api_log_schema.rb"
        File.open(filename, 'w:utf-8') do |file|
          ActiveRecord::Base.establish_connection("api_log_#{Rails.env}".to_sym)
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end

      # desc 'Purge and load foo_test schema'
      task load: [:environment] do
        # like db:test:purge
        abcs = ActiveRecord::Base.configurations
        ActiveRecord::Base.clear_all_connections!

        ActiveRecord::Base.connection.drop_database('api_log_test')
        ActiveRecord::Base.connection.create_database('api_log_test', abcs['api_log_test'])

        # like db:test:load_schema
        ActiveRecord::Base.establish_connection('api_log_test')
        ActiveRecord::Schema.verbose = false
        load("#{Rails.root}/db/api_log_schema.rb")
      end

      task reload: [:environment] do
        Rake::Task['api_log:test:schema:dump'].invoke
        Rake::Task['api_log:test:schema:load'].invoke
      end
    end
  end
end
