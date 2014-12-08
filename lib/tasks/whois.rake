DATABASES = [
  { database: 'whois_public', host: 'localhost', adapter: 'postgresql', encoding: 'unicode',
    pool: '5', username: 'whois', password: 'test', port: '5432' },
  { database: 'whois_private', host: 'localhost', adapter: 'postgresql', encoding: 'unicode',
    pool: '5', username: 'whois', password: 'test', port: '5432' }
]


namespace :whois do
  task :load_config do
    require 'active_record'
    require 'pg'
  end


  desc 'Create whois databases'
  task :create => [ :load_config ] do
    DATABASES.each do |conf|
      create_database(conf)
      migrate
    end
  end

  task 'Migrate whois databases'
  task :migrate => [ :load_config ] do
    DATABASES.each do |conf|
      ActiveRecord::Base.establish_connection(conf)
      migrate
    end
  end

  def create_database(conf)
    ActiveRecord::Base.establish_connection(conf.merge(database: 'postgres'))
    ActiveRecord::Base.connection.create_database(conf[:database])
    ActiveRecord::Base.establish_connection(conf)
  end

  def migrate
    CreateWhoisBase.up
  end
end

class CreateWhoisBase < ActiveRecord::Migration
  def self.up
    create_table :domains do |t|
      t.string :name
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drob_table :domains
  end
end
