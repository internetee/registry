require 'test_helper'

class APIDomainContactsTest < ApplicationIntegrationTest
  def setup
    # Mock DNSValidator to return success
    @original_validate = DNSValidator.method(:validate)
    DNSValidator.define_singleton_method(:validate) { |**args| { errors: [] } }
  end
  
  def teardown
    # Restore original validate method
    DNSValidator.define_singleton_method(:validate, @original_validate)
  end
  
  def test_replace_all_tech_contacts_of_the_current_registrar
    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'william-001',
                                                 new_contact_id: 'john-001' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_nil domains(:shop).tech_contacts.find_by(code: 'william-001')
    assert domains(:shop).tech_contacts.find_by(code: 'john-001')
    assert domains(:airport).tech_contacts.find_by(code: 'john-001')
  end

  def test_skip_discarded_domains
    domains(:airport).update!(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])

    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'william-001',
                                                 new_contact_id: 'john-001' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert domains(:airport).tech_contacts.find_by(code: 'william-001')
  end

  def test_return_affected_domains_in_alphabetical_order
    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'william-001',
                                                 new_contact_id: 'john-001' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :ok
    assert_equal ({ code: 1000, message: 'Command completed successfully', data: { affected_domains: %w[airport.test shop.test],
                    skipped_domains: [] }}),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_return_skipped_domains_in_alphabetical_order
    domains(:shop).update!(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])
    domains(:airport).update!(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])

    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'william-001',
                                                 new_contact_id: 'john-001' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :ok
    assert_equal %w[airport.test shop.test], JSON.parse(response.body,
                                                        symbolize_names: true)[:data][:skipped_domains]
  end

  def test_keep_other_tech_contacts_intact
    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'william-001',
                                                 new_contact_id: 'john-001' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert domains(:shop).tech_contacts.find_by(code: 'acme-ltd-001')
  end

  def test_keep_admin_contacts_intact
    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'william-001',
                                                 new_contact_id: 'john-001' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert domains(:airport).admin_contacts.find_by(code: 'william-001')
  end

  def test_restrict_contacts_to_the_current_registrar
    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'jack-001',
                                                 new_contact_id: 'william-002' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :not_found
    assert_equal ({ code: 2303, message: 'Object does not exist' }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_non_existent_current_contact
    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'non-existent',
                                                 new_contact_id: 'john-001' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response :not_found
    assert_equal ({ code: 2303, message: 'Object does not exist' }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_non_existent_new_contact
    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'william-001',
                                                 new_contact_id: 'non-existent' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response :not_found
    assert_equal ({code: 2303, message: 'Object does not exist'}),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_disallow_invalid_new_contact
    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'william-001',
                                                 new_contact_id: 'invalid' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response :bad_request
    assert_equal ({ code: 2304, message: 'New contact must be valid', data: {} }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_disallow_self_replacement
    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'william-001',
                                                 new_contact_id: 'william-001' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response :bad_request
    assert_equal ({ code: 2304, message: 'New contact must be different from current', data: {} }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_tech_bulk_changed_when_domain_update_prohibited
    domains(:shop).update!(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])

    shop_tech_contact = Contact.find_by(code: 'william-001')
    assert domains(:shop).tech_contacts.include?(shop_tech_contact)

    patch '/repp/v1/domains/contacts', params: { current_contact_id: 'william-001',
                                                 new_contact_id: 'john-001' },
                                                 headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :ok
    assert_equal ({ code: 1000,
                    message: 'Command completed successfully',
                    data: { affected_domains: ["airport.test"],
                    skipped_domains: ["shop.test"] }}),
            JSON.parse(response.body, symbolize_names: true)
  end

  private

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials('test_bestnames', 'testtest')
  end
end
