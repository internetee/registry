# lib/tasks/setup_report_user.rake

namespace :db do
  desc 'Create read-only report_user with access to public schema'
  task :create_report_user => :environment do
    require 'io/console'

    db_name = ENV['DB_NAME'] || ActiveRecord::Base.connection.current_database

    print 'Enter password for report_user (or set REPORT_USER_PASSWORD env var): '
    password = ENV['REPORT_USER_PASSWORD'] || $stdin.noecho(&:gets).chomp
    puts "\n"

    conn = ActiveRecord::Base.connection

    begin
      puts 'Creating report_user...'
      conn.execute("CREATE USER report_user WITH PASSWORD '#{password}';")
    rescue ActiveRecord::StatementInvalid => e
      puts "Skipping user creation: #{e.message}"
    end

    puts 'Granting privileges to report_user...'

    conn.execute("GRANT CONNECT ON DATABASE #{db_name} TO report_user;")
    conn.execute('GRANT USAGE ON SCHEMA public TO report_user;')
    conn.execute('GRANT SELECT ON ALL TABLES IN SCHEMA public TO report_user;')
    conn.execute('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO report_user;')

    puts 'Revoking write permissions...'
    conn.execute('REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM report_user;')
    conn.execute('REVOKE ALL ON SCHEMA public FROM report_user;')
    conn.execute('GRANT USAGE ON SCHEMA public TO report_user;')

    puts "✅ report_user setup complete for database '#{db_name}'"
  end
end
