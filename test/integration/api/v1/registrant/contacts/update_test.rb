require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiV1ContactUpdateTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:john)

    @original_address_processing = Setting.address_processing
    @original_fax_enabled_setting = ENV['fax_enabled']

    @user = users(:registrant)
  end

  teardown do
    Setting.address_processing = @original_address_processing
    ENV['fax_enabled'] = @original_fax_enabled_setting
  end

  def test_update_contact
    @contact.update!(name: 'John',
                     email: 'john@shop.test',
                     phone: '+111.1')

    patch api_v1_registrant_contact_path(@contact.uuid), params: { name: 'William',
                                                                   email: 'william@shop.test',
                                                                   phone: '+222.2' },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    assert_response :ok
    @contact.reload

    assert_equal 'William', @contact.name
    assert_equal 'william@shop.test', @contact.email
    assert_equal '+222.2', @contact.phone
  end

  def test_notify_registrar
    assert_difference -> { @contact.registrar.notifications.count } do
      patch api_v1_registrant_contact_path(@contact.uuid), params: { name: 'new name' },
            as: :json,
            headers: { 'HTTP_AUTHORIZATION' => auth_token }
    end
    notification = @contact.registrar.notifications.last
    assert_equal 'Contact john-001 has been updated by registrant', notification.text
  end

  def test_update_fax_when_enabled
    @contact.update!(fax: '+666.6')
    ENV['fax_enabled'] = 'true'

    patch api_v1_registrant_contact_path(@contact.uuid), params: { fax: '+777.7' },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }

    assert_response :ok
    @contact.reload
    assert_equal '+777.7', @contact.fax
  end

  def test_fax_cannot_be_updated_when_disabled
    ENV['fax_enabled'] = 'false'

    patch api_v1_registrant_contact_path(@contact.uuid), params: { fax: '+823.7' },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }

    assert_response :bad_request
    @contact.reload
    assert_not_equal '+823.7', @contact.fax

    error_msg = 'Fax processing is disabled and therefore cannot be updated'
    assert_equal ({ errors: [{ address: [error_msg] }] }), JSON.parse(response.body,
                                                                      symbolize_names: true)
  end

  def test_update_address_when_enabled
    Setting.address_processing = true

    patch api_v1_registrant_contact_path(@contact.uuid), params: { address: { city: 'new city',
                                                                              street: 'new street',
                                                                              zip: '92837',
                                                                              country_code: 'RU',
                                                                              state: 'new state' } },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }

    assert_response :ok
    @contact.reload
    assert_equal Contact::Address.new('new street', '92837', 'new city', 'new state', 'RU'),
                 @contact.address
  end

  def test_address_is_optional_when_enabled
    @contact.update!(street: 'any', zip: 'any', city: 'any', state: 'any', country_code: 'US')
    Setting.address_processing = true

    patch api_v1_registrant_contact_path(@contact.uuid), params: { name: 'any' },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }

    assert_response :ok
  end

  def test_address_cannot_be_updated_when_disabled
    @contact.update!(street: 'old street')
    Setting.address_processing = false

    patch api_v1_registrant_contact_path(@contact.uuid),
          params: { address: { street: 'new street' } },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    @contact.reload

    assert_response :bad_request
    assert_not_equal 'new street', @contact.street

    error_msg = 'Address processing is disabled and therefore cannot be updated'
    assert_equal ({ errors: [{ address: [error_msg] }] }), JSON.parse(response.body,
                                                                      symbolize_names: true)
  end

  def test_disclose_private_persons_data
    @contact.update!(ident_type: Contact::PRIV,
                     disclosed_attributes: %w[])

    patch api_v1_registrant_contact_path(@contact.uuid),
          params: { disclosed_attributes: %w[name] },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    @contact.reload

    assert_response :ok
    assert_equal %w[name], @contact.disclosed_attributes
  end

  def test_conceal_private_persons_data
    @contact.update!(ident_type: Contact::PRIV, disclosed_attributes: %w[name])

    patch api_v1_registrant_contact_path(@contact.uuid),
          params: { disclosed_attributes: [] },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }

    @contact.reload

    assert_response :ok
    assert_empty @contact.disclosed_attributes
  end

  def test_legal_persons_disclosed_attributes_cannot_be_changed
    @contact = contacts(:acme_ltd)

    # contacts(:acme_ltd).ident
    assert_equal '1234567', @contact.ident

    assert_equal Contact::ORG, @contact.ident_type
    assert_equal 'US', @contact.ident_country_code
    @contact.update!(disclosed_attributes: %w[])
    assert_equal 'US-1234', @user.registrant_ident

    assert_no_changes -> { @contact.disclosed_attributes } do
      patch api_v1_registrant_contact_path(@contact.uuid),
            params: { disclosed_attributes: %w[name] },
            as: :json,
            headers: { 'HTTP_AUTHORIZATION' => auth_token }
      @contact.reload
    end
    assert_response :bad_request

    error_msg = "Legal person's data is visible by default and cannot be concealed." \
                ' Please remove this parameter.'
    assert_equal ({ errors: [{ disclosed_attributes: [error_msg] }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_return_contact_details
    patch api_v1_registrant_contact_path(@contact.uuid), params: { name: 'new name' },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
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
                    statuses: @contact.statuses,
                    disclosed_attributes: @contact.disclosed_attributes }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_errors
    patch api_v1_registrant_contact_path(@contact.uuid), params: { phone: 'invalid' },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }

    assert_response :bad_request
    assert_equal ({ errors: { phone: ['Phone nr is invalid'] } }), JSON.parse(response.body,
                                                                              symbolize_names: true)
  end

  def test_unmanaged_contact_cannot_be_updated
    assert_equal 'US-1234', @user.registrant_ident
    @contact.update!(ident: '12345')

    patch api_v1_registrant_contact_path(@contact.uuid), params: { name: 'new name' },
          as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    @contact.reload

    assert_response :not_found
    assert_not_equal 'new name', @contact.name
  end

  def test_non_existent_contact
    patch api_v1_registrant_contact_path('non-existent'),
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
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
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
