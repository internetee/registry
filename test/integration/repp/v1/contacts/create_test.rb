require 'test_helper'

Company = Struct.new(:registration_number, :company_name, :status)

class ReppV1ContactsCreateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"
    @company_register_stub = CompanyRegister::Client.new

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_creates_new_contact
    request_body = {
      contact: {
        name: 'Donald Trump',
        phone: '+372.51111112',
        email: 'donald@trumptower.com',
        ident: {
          ident_type: 'priv',
          ident_country_code: 'EE',
          ident: '39708290069',
        },
      },
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    contact = Contact.find_by(code: json[:data][:contact][:code])
    assert contact.present?

    assert_equal(request_body[:contact][:name], contact.name)
    assert_equal(request_body[:contact][:phone], contact.phone)
    assert_equal(request_body[:contact][:email], contact.email)
    assert_equal(request_body[:contact][:ident][:ident_type], contact.ident_type)
    assert_equal(request_body[:contact][:ident][:ident_country_code], contact.ident_country_code)
    assert_equal(request_body[:contact][:ident][:ident], contact.ident)
  end

  def test_removes_postal_info_when_contact_created
    request_body = {
      contact: {
        name: 'Donald Trump',
        phone: '+372.51111111',
        email: 'donald@trump.com',
        ident: {
          ident_type: 'priv',
          ident_country_code: 'EE',
          ident: '39708290069',
        },
        addr: {
          city: 'Tallinn',
          street: 'Wismari 13',
          zip: '12345',
          country_code: 'EE',
        },
      },
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1100, json[:code]
    assert_equal 'Command completed successfully; Postal address data discarded', json[:message]

    contact = Contact.find_by(code: json[:data][:contact][:code])
    assert contact.present?

    assert_nil contact.city
    assert_nil contact.street
    assert_nil contact.zip
    assert_nil contact.country_code
  end

  def test_requires_contact_address_when_processing_enabled
    Setting.address_processing = true

    request_body = {
      "contact": {
        "name": 'Donald Trump',
        "phone": '+372.51111112',
        "email": 'donald@trumptower.com',
        "ident": {
          'ident_type': 'priv',
          'ident_country_code': 'EE',
          'ident': '39708290069',
        },
      },
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2003, json[:code]
    assert json[:message].include? 'param is missing or the value is empty'

    Setting.address_processing = false
  end

  def test_validates_ident_code
    request_body = {
      "contact": {
        "name": 'Donald Trump',
        "phone": '+372.51111112',
        "email": 'donald@trumptower.com',
        "ident": {
          "ident_type": 'priv',
          "ident_country_code": 'EE',
          "ident": '123123123',
        },
      },
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2005, json[:code]
    assert json[:message].include? 'Ident code does not conform to national identification number format'
  end

  def test_attaches_legaldoc_if_present
    request_body = {
      contact: {
        name: 'Donald Trump',
        phone: '+372.51111112',
        email: 'donald@trumptower.com',
        ident: {
          ident_type: 'priv',
          ident_country_code: 'EE',
          ident: '39708290069',
        },
        legal_document: {
          type: 'pdf',
          body: ('test' * 2000).to_s,
        },
      },
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    contact = Contact.find_by(code: json[:data][:contact][:code])
    assert contact.legal_documents.any?
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    request_body = {
      contact: {
        name: 'Donald Trump',
        phone: '+372.51111112',
        email: 'donald@trumptower.com',
        ident: {
          ident_type: 'priv',
          ident_country_code: 'EE',
          ident: '39708290069',
        },
      },
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end

  # def test_returns_error_response_if_company_not_existed
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', 'K')]
  #     end
  #     object
  #   end

  #   request_body = {
  #     "contact": {
  #       "name": 'Donald Trump',
  #       "phone": '+372.51111112',
  #       "email": 'donald@trumptower.com',
  #       "ident": {
  #         "ident_type": 'org',
  #         "ident_country_code": 'EE',
  #         "ident": '70000313',
  #       },
  #     },
  #   }

  #   post '/repp/v1/contacts', headers: @auth_headers, params: request_body
  #   json = JSON.parse(response.body, symbolize_names: true)

  #   assert_response :bad_request
  #   assert_equal 2003, json[:code]
  #   puts json[:message]
  #   assert json[:message].include? 'Company is not registered'

  #   CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  # end

  def test_contact_created_with_existed_company
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('1234567', 'ACME Ltd', 'R')]
      end
      object
    end

    request_body = {
      "contact": {
        "name": 'Donald Trump',
        "phone": '+372.51111112',
        "email": 'donald@trumptower.com',
        "ident": {
          "ident_type": 'org',
          "ident_country_code": 'EE',
          "ident": '70000313',
        },
      },
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end
end
