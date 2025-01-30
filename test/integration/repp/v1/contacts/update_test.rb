require 'test_helper'

class ReppV1ContactsUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @contact = contacts(:john)
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_updates_contact
    request_body =  {
      "contact": {
        "email": "donaldtrump@yandex.ru"
      }
    }

    put "/repp/v1/contacts/#{@contact.code}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    contact = Contact.find_by(code: json[:data][:contact][:code])
    assert contact.present?

    assert_equal(request_body[:contact][:email], contact.email)
  end

  def test_removes_postal_info_when_updated
    request_body = {
      "contact": {
        "addr": {
          "city": "Tallinn",
          "street": "Wismari 13",
          "zip": "12345",
          "country_code": "EE"
        }
      }
    }

    put "/repp/v1/contacts/#{@contact.code}", headers: @auth_headers, params: request_body
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

  def test_can_not_change_ident_code
    request_body =  {
      "contact": {
        "name": "Donald Trumpster",
        "ident": {
          "ident_type": "priv",
          "ident_country_code": "US",
          "ident": "12345"
        }
      }
    }

    put "/repp/v1/contacts/#{@contact.code}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    @contact.reload
    assert_not @contact.ident == 12345
    assert_response :bad_request
    assert_equal 2308, json[:code]
    assert json[:message].include? 'Ident update is not allowed. Consider creating new contact object'
  end

  def test_attaches_legaldoc_if_present
    request_body = {
      contact: {
        email: 'donaldtrump@yandex.ru',
        legal_document: {
          type: 'pdf',
          body: ('test' * 2000).to_s,
        },
      },
    }

    put "/repp/v1/contacts/#{@contact.code}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    @contact.reload
    assert @contact.legal_documents.any?
  end

  def test_returns_error_if_ident_wrong_format
    request_body = {
      contact: {
        ident: {
          ident: '123',
        }
      }
    }

    put "/repp/v1/contacts/#{@contact.code}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2308, json[:code]
    assert_equal 'Ident update is not allowed. Consider creating new contact object', json[:message]
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    request_body =  {
      "contact": {
        "email": "donaldtrump@yandex.ru"
      }
    }

    put "/repp/v1/contacts/#{@contact.code}", headers: @auth_headers, params: request_body
    put "/repp/v1/contacts/#{@contact.code}", headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end

  def test_validates_phone_number_after_update
    @contact.update!(
      phone: '+372.555666777',
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '12345678'
    )

    request_body = {
      contact: {
        phone: '+372.123456789'
      }
    }

    assert_enqueued_with(job: OrgRegistrantPhoneCheckerJob) do
      put "/repp/v1/contacts/#{@contact.code}", headers: @auth_headers, params: request_body
    end

    assert_response :ok
    json = JSON.parse(response.body, symbolize_names: true)
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    @contact.reload
    assert_equal '+372.123456789', @contact.phone
  end
end
