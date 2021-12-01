module Actions
  module GetAccrResultsFromAnotherDb
    extend self

    def list_of_accredated_users
      establish_connect_to_different_db ENV['demo_registry_db_name'].to_sym

      accr_users = []
      User.where.not(accreditation_date: nil).each do |u|
        accr_users << u
      end

      return_to_current_db

      accr_users
    rescue Exception
      return_to_current_db
    end

    def current_registrars_users(registrar_name:)
      establish_connect_to_different_db ENV['demo_registry_db_name'].to_sym
      # create_mock_user(registrar_name)

      accr_users = []

      r = Registrar.find_by(name: registrar_name)

      if r.nil?
        return_to_current_db
        return accr_users
      end

      r.api_users.where.not(accreditation_date: nil).each do |u|
        accr_users << u
      end

      return_to_current_db

      accr_users
    rescue Exception
      return_to_current_db
    end

    def userapi_from_another_db(user_api:)
      establish_connect_to_different_db ENV['demo_registry_db_name'].to_sym

      user = User.find_by(username: user_api.name, identity_code: user_api.identity_code)

      if user.nil?
        return_to_current_db
        return
      end

      return_to_current_db

      user
    rescue Exception
      return_to_current_db
    end

    private

    def create_mock_user(registrar_name)
      r = Registrar.new
      r.name = registrar_name
      r.vat_no = '321'
      r.reg_no = '123'
      r.phone = '372.534345345'
      r.email = 'test_rer@test.ee'
      r.billing_email = 'test_rer@test.ee'
      r.address_country_code = 'EE'
      r.address_city = 'Tallinn'
      r.address_street = 'Pelguranna'
      r.reference_no = '2254234'
      r.accounting_customer_code = '3323'
      r.code = 'QWEE:3444'

      if r.save
        create_mock_api(r.id)
      else
        p r.errors
      end
    end

    def create_mock_api(reg_id)
      a = ApiUser.new
      a.username = 'oleghasjanov'
      a.email = 'test_api@eesti.ee'
      a.identity_code = '38903110313'
      a.roles = ['super']
      a.country_code = 'EE'
      a.registrar_id = reg_id
      a.accreditation_date = Time.zone.now - 10.minutes
      a.plain_text_password = '1222password'

      if a.save
        p 'success'
      else
        p a.errors
      end
    end

    def establish_connect_to_different_db(db_name)
      ActiveRecord::Base.establish_connection db_name
    end

    def return_to_current_db
      ActiveRecord::Base.establish_connection Rails.env.to_sym
    end
  end
end
