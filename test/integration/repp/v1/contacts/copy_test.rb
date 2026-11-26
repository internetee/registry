require 'test_helper'

class ReppV1ContactsCopyTest < ActionDispatch::IntegrationTest
  def setup
    @contact = contacts(:john)
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")

    @auth_headers = { 'Authorization' => "Basic #{token}" }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_copies_contact_under_same_registrar
    original_attributes = @contact.attributes
    domain_ids = @contact.domain_ids
    registrant_domain_ids = @contact.registrant_domain_ids
    assert domain_ids.any?

    assert_difference -> { @user.registrar.contacts.count } do
      post "/repp/v1/contacts/copy/#{@contact.code}", headers: @auth_headers
    end
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]

    copy = Contact.find_by!(code: json[:data][:contact][:code])
    assert_equal @user.registrar, copy.registrar
    assert_equal @contact, copy.original
    %w[name email phone ident ident_type ident_country_code].each do |attr|
      assert_equal @contact[attr], copy[attr], attr
    end
    refute_equal @contact.code, copy.code
    assert_match(/\A#{@user.registrar.code.upcase}:[0-9A-F]{8}\z/, copy.code)
    refute_equal @contact.auth_info, copy.auth_info
    refute_equal @contact.uuid, copy.uuid
    assert_empty copy.domains
    assert_empty copy.registrant_domains

    @contact.reload
    assert_equal original_attributes, @contact.attributes
    assert_equal domain_ids.sort, @contact.domain_ids.sort
    assert_equal registrant_domain_ids.sort, @contact.registrant_domain_ids.sort
  end

  def test_copy_does_not_inherit_statuses_or_identity_verification
    @contact.update_columns(statuses: [Contact::SERVER_UPDATE_PROHIBITED],
                            status_notes: { Contact::SERVER_UPDATE_PROHIBITED => 'note' },
                            verified_at: Time.zone.now, verification_id: 'abc',
                            ident_request_sent_at: Time.zone.now)

    post "/repp/v1/contacts/copy/#{@contact.code}", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    copy = Contact.find_by!(code: json[:data][:contact][:code])
    assert_equal [Contact::OK], copy.statuses
    assert_empty copy.status_notes
    assert_nil copy.verified_at
    assert_nil copy.verification_id
    assert_nil copy.ident_request_sent_at
  end

  def test_creates_new_contact_even_if_identical_exists
    post "/repp/v1/contacts/copy/#{@contact.code}", headers: @auth_headers
    first_copy = Contact.find_by!(code: JSON.parse(response.body)['data']['contact']['code'])
    # identical lookup also compares stored statuses
    @contact.update_columns(statuses: first_copy.read_attribute(:statuses))
    assert_equal first_copy, @contact.identical(@user.registrar)

    assert_difference -> { @user.registrar.contacts.count } do
      post "/repp/v1/contacts/copy/#{@contact.code}", headers: @auth_headers
    end
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    refute_includes [@contact.code, first_copy.code], json[:data][:contact][:code]
  end

  def test_updates_of_copy_and_source_are_independent
    post "/repp/v1/contacts/copy/#{@contact.code}", headers: @auth_headers
    copy = Contact.find_by!(code: JSON.parse(response.body)['data']['contact']['code'])

    put "/repp/v1/contacts/#{copy.code}", headers: @auth_headers,
                                          params: { contact: { email: 'copy@inbox.test' } }
    assert_response :ok
    put "/repp/v1/contacts/#{@contact.code}", headers: @auth_headers,
                                              params: { contact: { name: 'John Source' } }
    assert_response :ok

    assert_equal 'copy@inbox.test', copy.reload.email
    assert_equal 'John', copy.name
    assert_equal 'john@inbox.test', @contact.reload.email
    assert_equal 'John Source', @contact.name
  end

  def test_returns_error_when_source_is_invalid
    contact = contacts(:invalid)

    assert_no_difference 'Contact.count' do
      post "/repp/v1/contacts/copy/#{contact.code}", headers: @auth_headers
    end

    assert_response :bad_request
  end

  def test_returns_error_when_not_found
    post '/repp/v1/contacts/copy/nonexistent:code', headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
  end

  def test_cannot_copy_contact_of_another_registrar
    assert_no_difference 'Contact.count' do
      post "/repp/v1/contacts/copy/#{contacts(:jack).code}", headers: @auth_headers
    end
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
  end

  def test_returns_error_when_user_is_not_authorized
    @user.update!(roles: ['billing'])

    assert_no_difference 'Contact.count' do
      post "/repp/v1/contacts/copy/#{@contact.code}", headers: @auth_headers
    end
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal 2201, json[:code]
  end
end
