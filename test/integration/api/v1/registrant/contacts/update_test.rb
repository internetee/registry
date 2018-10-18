require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiV1ContactUpdateTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:john)

    @original_address_processing_setting = Setting.address_processing
    @original_business_registry_cache_setting = Setting.days_to_keep_business_registry_cache
    @original_fax_enabled_setting = ENV['fax_enabled']

    Setting.days_to_keep_business_registry_cache = 1
    travel_to Time.zone.parse('2010-07-05')
  end

  teardown do
    Setting.address_processing = @original_address_processing_setting
    Setting.days_to_keep_business_registry_cache = @original_business_registry_cache_setting
    ENV['fax_enabled'] = @original_fax_enabled_setting
  end

  def test_update_contact
    patch api_v1_registrant_contact_path(@contact.uuid), { name: 'new name',
                                                           email: 'new-email@coldmail.test',
                                                           phone: '+666.6' },
          'HTTP_AUTHORIZATION' => auth_token
    assert_response :ok
    @contact.reload
    assert_equal 'new name', @contact.name
    assert_equal 'new-email@coldmail.test', @contact.email
    assert_equal '+666.6', @contact.phone
  end

  def test_notify_registrar
    assert_difference -> { @contact.registrar.notifications.count } do
      patch api_v1_registrant_contact_path(@contact.uuid), { name: 'new name' },
            'HTTP_AUTHORIZATION' => auth_token
    end
    notification = @contact.registrar.notifications.last
    assert_equal 'Contact john-001 has been updated by registrant', notification.text
  end

  def test_update_fax_when_enabled
    ENV['fax_enabled'] = 'true'
    @contact = contacts(:william)

    patch api_v1_registrant_contact_path(@contact.uuid), { 'fax' => '+777.7' },
          'HTTP_AUTHORIZATION' => auth_token

    assert_response :ok
    @contact.reload
    assert_equal '+777.7', @contact.fax
  end

  def test_fax_cannot_be_updated_when_disabled
    ENV['fax_enabled'] = 'false'

    patch api_v1_registrant_contact_path(@contact.uuid), { 'fax' => '+823.7' },
          'HTTP_AUTHORIZATION' => auth_token

    assert_response :bad_request
    @contact.reload
    assert_not_equal '+823.7', @contact.fax

    error_msg = 'Fax processing is disabled and therefore cannot be updated'
    assert_equal ({ errors: [{ address: [error_msg] }] }), JSON.parse(response.body,
                                                                      symbolize_names: true)
  end

  def test_update_address_when_enabled
    Setting.address_processing = true

    patch api_v1_registrant_contact_path(@contact.uuid), { 'address[city]' => 'new city',
                                                           'address[street]' => 'new street',
                                                           'address[zip]' => '92837',
                                                           'address[country_code]' => 'RU',
                                                           'address[state]' => 'new state' },
          'HTTP_AUTHORIZATION' => auth_token

    assert_response :ok
    @contact.reload
    assert_equal Contact::Address.new('new street', '92837', 'new city', 'new state', 'RU'),
                 @contact.address
  end

  def test_address_is_optional_when_enabled
    @contact = contacts(:william)
    Setting.address_processing = true

    patch api_v1_registrant_contact_path(@contact.uuid), { 'name' => 'any' },
          'HTTP_AUTHORIZATION' => auth_token

    assert_response :ok
  end

  def test_address_cannot_be_updated_when_disabled
    @contact = contacts(:william)
    @original_address = @contact.address
    Setting.address_processing = false

    patch api_v1_registrant_contact_path(@contact.uuid), { 'address[city]' => 'new city' },
          'HTTP_AUTHORIZATION' => auth_token

    @contact.reload
    assert_response :bad_request
    assert_equal @original_address, @contact.address

    error_msg = 'Address processing is disabled and therefore cannot be updated'
    assert_equal ({ errors: [{ address: [error_msg] }] }), JSON.parse(response.body,
                                                                      symbolize_names: true)
  end

  def test_return_contact_details
    patch api_v1_registrant_contact_path(@contact.uuid), { name: 'new name' },
          'HTTP_AUTHORIZATION' => auth_token
    assert_equal ({ id: @contact.uuid,
                    name: 'new name',
                    code: @contact.code,
                    fax: @contact.fax,
                    ident: {
                      code: @contact.ident,
                      type: @contact.ident_type,
                      country_code: @contact.ident_country_code,
                    },
                    email: @contact.email,
                    phone: @contact.phone,
                    address: {
                      street: @contact.street,
                      zip: @contact.zip,
                      city: @contact.city,
                      state: @contact.state,
                      country_code: @contact.country_code,
                    },
                    auth_info: @contact.auth_info,
                    statuses: @contact.statuses }), JSON.parse(response.body, symbolize_names: true)
  end

  def test_errors
    patch api_v1_registrant_contact_path(@contact.uuid), { phone: 'invalid' },
          'HTTP_AUTHORIZATION' => auth_token

    assert_response :bad_request
    assert_equal ({ errors: { phone: ['Phone nr is invalid'] } }), JSON.parse(response.body,
                                                                              symbolize_names: true)
  end

  def test_contact_of_another_user_cannot_be_updated
    @contact = contacts(:jack)

    patch api_v1_registrant_contact_path(@contact.uuid), { name: 'any' },
          'HTTP_AUTHORIZATION' => auth_token

    assert_response :not_found
    @contact.reload
    assert_not_equal 'any', @contact.name
  end

  def test_non_existent_contact
    patch api_v1_registrant_contact_path('non-existent'), nil, 'HTTP_AUTHORIZATION' => auth_token
    assert_response :not_found
    assert_equal ({ errors: [{ base: ['Not found'] }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_anonymous_user
    patch api_v1_registrant_contact_path(@contact.uuid)
    assert_response :unauthorized
    assert_equal ({ errors: [{ base: ['Not authorized'] }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(users(:registrant))
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end