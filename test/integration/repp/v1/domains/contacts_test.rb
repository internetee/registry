require 'test_helper'

class ReppV1DomainsContactsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_shows_existing_domain_contacts
    get "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal @domain.admin_contacts.length, json[:data][:admin_contacts].length
    assert_equal @domain.tech_contacts.length, json[:data][:tech_contacts].length
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    get "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers
    get "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end

  def test_can_add_new_admin_contacts
    DNSValidator.stub :validate, { errors: [] } do
      new_contact = contacts(:john)
    refute  @domain.admin_contacts.find_by(code: new_contact.code).present?

    payload = { contacts: [ { code: new_contact.code, type: 'admin' } ] }
    post "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]

    assert @domain.admin_contacts.find_by(code: new_contact.code).present?
    end
  end

  def test_can_add_new_tech_contacts
    DNSValidator.stub :validate, { errors: [] } do
      new_contact = contacts(:john)
    refute  @domain.tech_contacts.find_by(code: new_contact.code).present?

    payload = { contacts: [ { code: new_contact.code, type: 'tech' } ] }
    post "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    @domain.reload

    assert @domain.tech_contacts.find_by(code: new_contact.code).present?
    end
  end

  def test_can_remove_admin_contacts
    DNSValidator.stub :validate, { errors: [] } do
      Spy.on_instance_method(Actions::DomainUpdate, :validate_email).and_return(true)

    contact = contacts(:john)
    payload = { contacts: [ { code: contact.code, type: 'admin' } ] }
    post "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    assert @domain.admin_contacts.find_by(code: contact.code).present?

    # Actually delete the contact
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]

    refute @domain.admin_contacts.find_by(code: contact.code).present?
    end
  end

  def test_can_remove_tech_contacts
    DNSValidator.stub :validate, { errors: [] } do
      Spy.on_instance_method(Actions::DomainUpdate, :validate_email).and_return(true)

    contact = contacts(:john)
    payload = { contacts: [ { code: contact.code, type: 'tech' } ] }
    post "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    assert @domain.tech_contacts.find_by(code: contact.code).present?

    # Actually delete the contact
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    @domain.reload
    contact.reload

    assert_response :ok
    assert_equal 1000, json[:code]

    refute @domain.tech_contacts.find_by(code: contact.code).present?
    end
  end

  def test_can_remove_all_admin_contacts_for_private_registrant
    DNSValidator.stub :validate, { errors: [] } do
      Spy.on_instance_method(Actions::DomainUpdate, :validate_email).and_return(true)

    @domain.registrant.update!(ident_type: 'priv')
    @domain.reload
    assert_not @domain.registrant.org?

    contact = @domain.admin_contacts.last

    payload = { contacts: [ { code: contact.code, type: 'admin' } ] }
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    @domain.reload
    assert_response :ok
    assert_equal 1000, json[:code]

    assert_empty @domain.admin_contacts
    end
  end

  def test_can_not_remove_one_and_only_contact
    Spy.on_instance_method(Actions::DomainUpdate, :validate_email).and_return(true)

    @domain.registrant.update!(ident_type: 'org')
    @domain.reload

    contact = @domain.admin_contacts.last

    payload = { contacts: [ { code: contact.code, type: 'admin' } ] }
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    @domain.reload
    assert_response :bad_request
    assert_equal 2306, json[:code]

    assert @domain.admin_contacts.any?
  end

  def test_cannot_remove_admin_contact_for_legal_entity
    @domain.registrant.update!(ident_type: 'org')
    @domain.reload
    assert @domain.registrant.org?
    
    contact = @domain.admin_contacts.last
    payload = { contacts: [ { code: contact.code, type: 'admin' } ] }
    
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)
    
    assert_response :bad_request
    assert_equal 2306, json[:code]
    assert @domain.admin_contacts.any?
  end

  def test_cannot_remove_admin_contact_for_underage_private_registrant
    @domain.registrant.update!(
      ident_type: 'birthday',
      ident: (Time.zone.now - 16.years).strftime('%Y-%m-%d')
    )
    @domain.reload
    assert @domain.registrant.priv?
    
    contact = @domain.admin_contacts.last
    payload = { contacts: [ { code: contact.code, type: 'admin' } ] }
    
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)
    
    assert_response :bad_request
    assert_equal 2306, json[:code]
    assert @domain.admin_contacts.any?
  end

  def test_can_remove_admin_contact_for_adult_private_registrant
    DNSValidator.stub :validate, { errors: [] } do
      @domain.registrant.update!(
        ident_type: 'birthday',
        ident: (Time.zone.now - 20.years).strftime('%Y-%m-%d')
      )
    @domain.reload
    assert @domain.registrant.priv?
    
    contact = @domain.admin_contacts.last
    payload = { contacts: [ { code: contact.code, type: 'admin' } ] }
    
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)
    
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_empty @domain.admin_contacts
    end
  end

  def test_cannot_remove_admin_contact_for_underage_estonian_id
    @domain.registrant.update!(
      ident_type: 'priv',
      ident: '61203150222',
      ident_country_code: 'EE'
    )
    @domain.reload
    assert @domain.registrant.priv?
    
    contact = @domain.admin_contacts.last
    payload = { contacts: [ { code: contact.code, type: 'admin' } ] }
    
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)
    
    assert_response :bad_request
    assert_equal 2306, json[:code]
    assert @domain.admin_contacts.any?
  end

  def test_can_remove_admin_contact_for_adult_estonian_id
    DNSValidator.stub :validate, { errors: [] } do
      @domain.registrant.update!(
        ident_type: 'priv',
        ident: '38903111310',
        ident_country_code: 'EE'
      )
    @domain.reload
    assert @domain.registrant.priv?
    
    contact = @domain.admin_contacts.last
    payload = { contacts: [ { code: contact.code, type: 'admin' } ] }
    
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)
    
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_empty @domain.admin_contacts
    end
  end
end
