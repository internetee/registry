require 'test_helper'

class ReppV1ContactsCreateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_creates_new_contact
    request_body =  {
      "contact": {
        "name": "Donald Trump",
        "phone": "+372.51111112",
        "email": "donald@trumptower.com",
        "ident": {
          "ident_type": "priv",
          "ident_country_code": "EE",
          "ident": "39708290069"
        }
      }
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    contact = Contact.find_by(code: json[:data][:contact][:id])
    assert contact.present?

    assert_equal(request_body[:contact][:name], contact.name)
    assert_equal(request_body[:contact][:phone], contact.phone)
    assert_equal(request_body[:contact][:email], contact.email)
    assert_equal(request_body[:contact][:ident][:ident_type], contact.ident_type)
    assert_equal(request_body[:contact][:ident][:ident_country_code], contact.ident_country_code)
    assert_equal(request_body[:contact][:ident][:ident], contact.ident)
  end

  def test_removes_postal_info_when_contact_created
    request_body =  {
      "contact": {
        "name": "Donald Trump",
        "phone": "+372.51111111",
        "email": "donald@trump.com",
        "ident": {
          "ident_type": "priv",
          "ident_country_code": "EE",
          "ident": "39708290069"
        },
        "addr": {
          "city": "Tallinn",
          "street": "Wismari 13",
          "zip": "12345",
          "country_code": "EE"
        }
      }
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1100, json[:code]
    assert_equal 'Command completed successfully; Postal address data discarded', json[:message]

    contact = Contact.find_by(code: json[:data][:contact][:id])
    assert contact.present?

    assert_nil contact.city
    assert_nil contact.street
    assert_nil contact.zip
    assert_nil contact.country_code
  end

  def test_requires_contact_address_when_processing_enabled
    Setting.address_processing = true

    request_body =  {
      "contact": {
        "name": "Donald Trump",
        "phone": "+372.51111112",
        "email": "donald@trumptower.com",
        "ident": {
          "ident_type": "priv",
          "ident_country_code": "EE",
          "ident": "39708290069"
        }
      }
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2003, json[:code]
    assert json[:message].include? 'param is missing or the value is empty'

    Setting.address_processing = false
  end

  def test_validates_ident_code
    request_body =  {
      "contact": {
        "name": "Donald Trump",
        "phone": "+372.51111112",
        "email": "donald@trumptower.com",
        "ident": {
          "ident_type": "priv",
          "ident_country_code": "EE",
          "ident": "123123123"
        }
      }
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2005, json[:code]
    assert json[:message].include? 'Ident code does not conform to national identification number format'
  end

  def test_attaches_legaldoc_if_present
    request_body =  {
      "contact": {
        "name": "Donald Trump",
        "phone": "+372.51111112",
        "email": "donald@trumptower.com",
        "ident": {
          "ident_type": "priv",
          "ident_country_code": "EE",
          "ident": "39708290069"
        },
      },
      "legal_document": {
        "type": "pdf",
        "body": "#{'test' * 2000}"
      }
    }

    post '/repp/v1/contacts', headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    contact = Contact.find_by(code: json[:data][:contact][:id])
    assert contact.legal_documents.any?
  end
end
