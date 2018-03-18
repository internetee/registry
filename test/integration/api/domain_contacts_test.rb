require 'test_helper'

class APIDomainContactsTest < ActionDispatch::IntegrationTest
  def test_replace_all_tech_contacts_of_the_current_registrar
    patch '/repp/v1/domains/contacts', { predecessor: 'william-001', successor: 'john-001' },
          { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_nil domains(:shop).tech_contacts.find_by(code: 'william-001')
    assert domains(:shop).tech_contacts.find_by(code: 'john-001')
    assert domains(:airport).tech_contacts.find_by(code: 'john-001')
  end

  def test_skip_discarded_domains
    domains(:airport).update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    patch '/repp/v1/domains/contacts', { predecessor: 'william-001', successor: 'john-001' },
          { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert domains(:airport).tech_contacts.find_by(code: 'william-001')
  end

  def test_return_affected_domains_in_alphabetical_order
    patch '/repp/v1/domains/contacts', { predecessor: 'william-001', successor: 'john-001' },
          { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :ok
    assert_equal ({ affected_domains: %w[airport.test shop.test],
                    skipped_domains: [] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_return_skipped_domains_in_alphabetical_order
    domains(:shop).update!(statuses: [DomainStatus::DELETE_CANDIDATE])
    domains(:airport).update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    patch '/repp/v1/domains/contacts', { predecessor: 'william-001', successor: 'john-001' },
          { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :ok
    assert_equal %w[airport.test shop.test], JSON.parse(response.body,
                                                        symbolize_names: true)[:skipped_domains]
  end

  def test_keep_other_tech_contacts_intact
    patch '/repp/v1/domains/contacts', { predecessor: 'william-001', successor: 'john-001' },
          { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert domains(:shop).tech_contacts.find_by(code: 'acme-ltd-001')
  end

  def test_keep_admin_contacts_intact
    patch '/repp/v1/domains/contacts', { predecessor: 'william-001', successor: 'john-001' },
          { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert domains(:airport).admin_contacts.find_by(code: 'william-001')
  end

  def test_restrict_contacts_to_the_current_registrar
    patch '/repp/v1/domains/contacts', { predecessor: 'jack-001', successor: 'william-002' },
          { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :bad_request
    assert_equal ({ error: { type: 'invalid_request_error',
                             param: 'predecessor',
                             message: 'No such contact: jack-001' } }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_non_existent_predecessor
    patch '/repp/v1/domains/contacts', { predecessor: 'non-existent', successor: 'john-001' },
          { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response :bad_request
    assert_equal ({ error: { type: 'invalid_request_error',
                             param: 'predecessor',
                             message: 'No such contact: non-existent' } }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_non_existent_successor
    patch '/repp/v1/domains/contacts', { predecessor: 'william-001', successor: 'non-existent' },
          { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response :bad_request
    assert_equal ({ error: { type: 'invalid_request_error',
                             param: 'successor',
                             message: 'No such contact: non-existent' } }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_disallow_self_replacement
    patch '/repp/v1/domains/contacts', { predecessor: 'william-001', successor: 'william-001' },
          { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response :bad_request
    assert_equal ({ error: { type: 'invalid_request_error',
                             message: 'Successor contact must be different from predecessor' } }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  private

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials('test_bestnames', 'testtest')
  end
end
