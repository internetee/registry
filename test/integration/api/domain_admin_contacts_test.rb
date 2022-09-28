require 'test_helper'

class APIDomainAdminContactsTest < ApplicationIntegrationTest
  setup do
    @admin_current = domains(:shop).admin_contacts.find_by(code: 'jane-001')
    domain = domains(:airport)
    domain.admin_contacts << @admin_current
    @admin_new = contacts(:william)

    @admin_new.update(ident: @admin_current.ident,
                      ident_type: @admin_current.ident_type,
                      ident_country_code: @admin_current.ident_country_code)
  end

  def test_replace_all_admin_contacts_when_ident_data_doesnt_match
    @admin_new.update(ident: '777' ,
                      ident_type: 'priv',
                      ident_country_code: 'LV')

    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                       new_contact_id: @admin_new.code },
                                             headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :bad_request
    assert_equal ({ code: 2304,
                    message: 'New and current admin contacts ident data must be identical',
                    data: {} }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_replace_all_admin_contacts_of_the_current_registrar
    assert @admin_new.identical_to?(@admin_current)
    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                       new_contact_id: @admin_new.code },
                                             headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_nil domains(:shop).admin_contacts.find_by(code: @admin_current.code)
    assert domains(:shop).admin_contacts.find_by(code: @admin_new.code)
    assert domains(:airport).admin_contacts.find_by(code: @admin_new.code)
  end

  def test_skip_discarded_domains
    domains(:airport).update!(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])

    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                       new_contact_id: @admin_new.code },
                                             headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert domains(:airport).admin_contacts.find_by(code: @admin_current.code)
  end

  def test_return_affected_domains_in_alphabetical_order
    domain = domains(:airport)
    domain.admin_contacts = [@admin_current]
    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                       new_contact_id: @admin_new.code },
                                             headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :ok
    assert_equal ({ code: 1000, message: 'Command completed successfully',
                    data: { affected_domains: %w[airport.test shop.test],
                            skipped_domains: [] } }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_return_skipped_domains_in_alphabetical_order
    domains(:shop).update!(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])
    domains(:airport).update!(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])

    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                 new_contact_id: @admin_new.code },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :ok
    assert_equal %w[airport.test shop.test], JSON.parse(response.body,
                                                        symbolize_names: true)[:data][:skipped_domains]
  end

  def test_keep_other_admin_contacts_intact
    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                 new_contact_id: @admin_new.code },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert domains(:airport).admin_contacts.find_by(code: 'john-001')
  end

  def test_keep_tech_contacts_intact
    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                 new_contact_id: @admin_new.code },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert domains(:airport).tech_contacts.find_by(code: 'william-001')
  end

  def test_restrict_contacts_to_the_current_registrar
    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                 new_contact_id: 'william-002' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :not_found
    assert_equal ({ code: 2303, message: 'Object does not exist' }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_non_existent_current_contact
    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: 'non-existent',
                                                 new_contact_id: @admin_new.code},
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response :not_found
    assert_equal ({ code: 2303, message: 'Object does not exist' }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_non_existent_new_contact
    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                 new_contact_id: 'non-existent' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response :not_found
    assert_equal ({code: 2303, message: 'Object does not exist'}),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_disallow_invalid_new_contact
    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                 new_contact_id: 'invalid' },
          headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response :bad_request
    assert_equal ({ code: 2304, message: 'New contact must be valid', data: {} }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_admin_bulk_changed_when_domain_update_prohibited
    domains(:shop).update!(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])
    domains(:airport).admin_contacts = [@admin_current]

    shop_admin_contact = Contact.find_by(code: 'jane-001')
    assert domains(:shop).admin_contacts.include?(shop_admin_contact)

    patch '/repp/v1/domains/admin_contacts', params: { current_contact_id: @admin_current.code,
                                                 new_contact_id: @admin_new.code },
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
