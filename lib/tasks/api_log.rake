namespace :api_log do
  namespace :schema do
    # desc 'Dump additional database schema'
    task :dump => [:environment] do
      filename = "#{Rails.root}/db/api_log_schema.rb"
      File.open(filename, 'w:utf-8') do |file|
        ActiveRecord::Base.establish_connection("api_log_#{Rails.env}")
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end
end
