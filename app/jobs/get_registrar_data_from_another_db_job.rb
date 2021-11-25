class AnotherDb < ActiveRecord::Base
  ActiveRecord::Base.establish_connection(
    {
      :adapter => 'postgresql',
      :database => 'registry_test',
      :host => ENV.fetch("APP_DBHOST") { "localhost" },
      :username => ENV.fetch("APP_DBUSER") { "postgres" },
      :password => 'postgres'
    }
  )
end

class GetRegistrarDataFromAnotherDbJob < ApplicationJob
  def perform()
    establish_connect_to_different_db

    Registrar.all.each do |r|
      p "++++++++"
      p r
      p "++++++++"
    end

  end

  def establish_connect_to_different_db
    ActiveRecord::Base.establish_connection(
      {
        :adapter => 'postgresql',
        :database => 'registry_test',
        :host => ENV.fetch("APP_DBHOST") { "localhost" },
        :username => ENV.fetch("APP_DBUSER") { "postgres" },
        :password => 'postgres'
      })
  end
end
