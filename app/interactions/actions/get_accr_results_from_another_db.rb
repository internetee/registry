module Actions
  module GetAccrResultsFromAnotherDb
    extend self

    def get_list_of_accredated_users
      begin
        establish_connect_to_different_db

        accr_users = []
        User.where.not(accreditation_date: nil) do |u|
          accr_users << u
        end
        return_to_current_db

        return accr_users
      rescue
        return_to_current_db
      end
    end

    def get_current_registrars_users(registrar_name:)
      begin
        establish_connect_to_different_db

        accr_users = []

        r = Registrar.find_by(name: registrar_name)

        return accr_users if r.nil?

        r.api_users.where.not(accreditation_date: nil) do |u|
          accr_users << u
        end

        return_to_current_db

        return accr_users
      rescue
        return_to_current_db
      end
    end

    private

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

    def return_to_current_db
      ActiveRecord::Base.establish_connection Rails.env.to_sym

      # if Rails.env.development?
      #   ActiveRecord::Base.establish_connection :development
      # elsif Rails.env.staging?
      #   ActiveRecord::Base.establish_connection :staging
      # elsif Rails.env.production?
      #   ActiveRecord::Base.establish_connection :production
      # end

    end
  end
end
