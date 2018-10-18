require 'test_helper'

class RegistrantAreaContactUpdateTest < ApplicationIntegrationTest
  setup do
    @domain = domains(:shop)
    @contact = contacts(:john)
    sign_in users(:registrant)

    @original_address_processing_setting = Setting.address_processing
    @original_business_registry_cache_setting = Setting.days_to_keep_business_registry_cache
    @original_fax_enabled_setting = ENV['fax_enabled']
    @original_registrant_api_base_url_setting = ENV['registrant_api_base_url']

    ENV['registrant_api_base_url'] = 'https://api.test'
    Setting.days_to_keep_business_registry_cache = 1
    travel_to Time.zone.parse('2010-07-05')
  end

  teardown do
    Setting.address_processing = @original_address_processing_setting
    Setting.days_to_keep_business_registry_cache = @original_business_registry_cache_setting
    ENV['fax_enabled'] = @original_fax_enabled_setting
    ENV['registrant_api_base_url'] = @original_registrant_api_base_url_setting
  end

  def test_form_is_pre_populated_with_contact_data
    visit edit_registrant_domain_contact_url(@domain, @contact)

    assert_field 'Name', with: 'John'
    assert_field 'Email', with: 'john@inbox.test'
    assert_field 'Phone', with: '+555.555'
  end

  def test_update_contact
    stub_auth_request

    request_body = { name: 'new name', email: 'new@inbox.test', phone: '+666.6' }
    headers = { 'Authorization' => 'Bearer test-access-token' }
    url = "https://api.test/api/v1/registrant/contacts/#{@contact.uuid}"
    update_request_stub = stub_request(:patch, url).with(body: request_body, headers: headers)
                            .to_return(body: '{}', status: 200)

    visit registrant_domain_contact_url(@domain, @contact)
    click_link_or_button 'Edit'

    fill_in 'Name', with: 'new name'
    fill_in 'Email', with: 'new@inbox.test'
    fill_in 'Phone', with: '+666.6'

    click_link_or_button 'Update contact'

    assert_requested update_request_stub
    assert_current_path registrant_domain_contact_path(@domain, @contact)
    assert_text 'Contact has been successfully updated'
  end

  def test_form_is_pre_populated_with_fax_when_enabled
    ENV['fax_enabled'] = 'true'
    @contact.update!(fax: '+111.1')

    visit edit_registrant_domain_contact_url(@domain, @contact)
    assert_field 'Fax', with: '+111.1'
  end

  def test_update_fax_when_enabled
    ENV['fax_enabled'] = 'true'
    stub_auth_request

    request_body = { email: 'john@inbox.test', name: 'John', phone: '+555.555', fax: '+222.2' }
    headers = { 'Authorization' => 'Bearer test-access-token' }
    url = "https://api.test/api/v1/registrant/contacts/#{@contact.uuid}"
    update_request_stub = stub_request(:patch, url).with(body: request_body, headers: headers)
                            .to_return(body: '{}', status: 200)

    visit edit_registrant_domain_contact_url(@domain, @contact)

    fill_in 'Fax', with: '+222.2'
    click_link_or_button 'Update contact'

    assert_requested update_request_stub
    assert_current_path registrant_domain_contact_path(@domain, @contact)
    assert_text 'Contact has been successfully updated'
  end

  def test_hide_fax_field_when_disabled
    visit edit_registrant_domain_contact_url(@domain, @contact)
    assert_no_field 'Fax'
  end

  def test_form_is_pre_populated_with_address_when_enabled
    Setting.address_processing = true
    @contact = contacts(:william)

    visit edit_registrant_domain_contact_url(@domain, @contact)

    assert_field 'Street', with: 'Main Street'
    assert_field 'Zip', with: '12345'
    assert_field 'City', with: 'New York'
    assert_field 'State', with: 'New York State'
    assert_select 'Country', selected: 'United States'
  end

  def test_update_address_when_enabled
    Setting.address_processing = true
    stub_auth_request

    request_body = { email: 'john@inbox.test',
                     name: 'John',
                     phone: '+555.555',
                     address: {
                       street: 'new street',
                       zip: '93742',
                       city: 'new city',
                       state: 'new state',
                       country_code: 'AT'
                     } }
    headers = { 'Authorization' => 'Bearer test-access-token' }
    url = "https://api.test/api/v1/registrant/contacts/#{@contact.uuid}"
    update_request_stub = stub_request(:patch, url).with(body: request_body, headers: headers)
                            .to_return(body: '{}', status: 200)

    visit edit_registrant_domain_contact_url(@domain, @contact)

    fill_in 'Street', with: 'new street'
    fill_in 'City', with: 'new city'
    fill_in 'State', with: 'new state'
    fill_in 'Zip', with: '93742'
    select 'Austria', from: 'Country'
    click_link_or_button 'Update contact'

    assert_requested update_request_stub
    assert_current_path registrant_domain_contact_path(@domain, @contact)
    assert_text 'Contact has been successfully updated'
  end

  def test_hide_address_field_when_disabled
    visit edit_registrant_domain_contact_url(@domain, @contact)
    assert_no_field 'Address'
    assert_no_field 'Street'
  end

  def test_unmanaged_contact_cannot_be_updated
    @contact.update!(ident: '12345')
    visit registrant_domain_contact_url(@domain, @contact)
    assert_no_button 'Edit'
    assert_no_link 'Edit'
  end

  def test_fail_gracefully
    stub_auth_request

    response_body = { errors: { name: ['Name is invalid'] } }.to_json
    headers = { 'Authorization' => 'Bearer test-access-token' }
    stub_request(:patch, "https://api.test/api/v1/registrant/contacts/#{@contact.uuid}")
      .with(headers: headers)
      .to_return(body: response_body, status: 400)

    visit edit_registrant_domain_contact_url(@domain, @contact)
    fill_in 'Name', with: 'invalid name'
    click_link_or_button 'Update contact'

    assert_current_path registrant_domain_contact_path(@domain, @contact)
    assert_text 'Name is invalid'
    assert_field 'Name', with: 'invalid name'
    assert_no_text 'Contact has been successfully updated'
  end

  private

  def stub_auth_request
    body = { ident: '1234', first_name: 'Registrant', last_name: 'User' }
    stub_request(:post, 'https://api.test/api/v1/registrant/auth/eid').with(body: body)
      .to_return(body: { access_token: 'test-access-token' }.to_json,
                 headers: { 'Content-type' => 'application/json' },
                 status: 200)
  end
end
