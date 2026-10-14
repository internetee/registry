require 'test_helper'

class ApiV1InternalRdapAccessEventsTest < ApplicationIntegrationTest
  def setup
    ENV['rdap_internal_api_shared_key'] = 'test-rdap-key'
    ENV['rdap_internal_api_allowed_ips'] = '127.0.0.1,::1'
    @header = { 'Authorization' => 'Basic test-rdap-key' }
    @grant = rdap_privilege_grants(:police_active)
  end

  def teardown
    ENV.delete('rdap_internal_api_shared_key')
    ENV.delete('rdap_internal_api_allowed_ips')
    super
  end

  # AC5 — happy path: 204 + empty body + exactly one row with posted values.
  def test_create_records_event_and_returns_204
    requested_at = 3.hours.ago.change(usec: 0)

    assert_difference 'RdapAccessEvent.count', 1 do
      post_event(domain_name: 'happy.ee', caller_ip: '198.51.100.5',
                 requested_at: requested_at.iso8601, result_code: 200)
    end

    assert_response :no_content
    assert_empty response.body

    event = RdapAccessEvent.last
    assert_equal 'happy.ee', event.domain_name
    assert_equal '198.51.100.5', event.caller_ip
    assert_equal 200, event.result_code
    assert_equal requested_at.to_i, event.requested_at.to_i
  end

  # AC6 — route reachable at the explicit path (no resources siblings).
  def test_route_reachable_at_explicit_path
    assert_routing({ method: 'post', path: '/api/v1/internal/rdap/access-events' },
                   { controller: 'api/v1/internal/rdap/access_events', action: 'create' })
  end

  # AC7 — grant resolved by uuid AND by id; snapshots equal the grant fixture.
  def test_create_snapshots_organization_accessor_category_grant_ref_from_grant
    post_event(grant_id: @grant.uuid)
    assert_response :no_content

    event = RdapAccessEvent.last
    assert_equal @grant.organization, event.organization_name
    assert_equal @grant.full_name, event.accessor_name
    assert_equal @grant.category, event.category
    assert_equal @grant.uuid, event.grant_ref

    # Resolve by numeric id as well.
    post_event(grant_id: @grant.id)
    assert_response :no_content
    assert_equal @grant.uuid, RdapAccessEvent.last.grant_ref
  end

  # AC8 — grant with NULL organization: organization_name persists NULL, others set.
  def test_create_with_grant_without_organization
    grant = rdap_privilege_grants(:no_organization)
    assert_nil grant.organization

    post_event(grant_id: grant.uuid)
    assert_response :no_content

    event = RdapAccessEvent.last
    assert_nil event.organization_name
    assert_equal grant.full_name, event.accessor_name
    assert_equal grant.category, event.category
    assert_equal grant.uuid, event.grant_ref
  end

  # AC9 — unknown grant: 404 + { message: } + no row.
  def test_create_with_unknown_grant_returns_404
    assert_no_difference 'RdapAccessEvent.count' do
      post_event(grant_id: 'does-not-exist')
    end

    assert_response :not_found
    assert_equal 'Grant not found', json_body[:message]
  end

  # AC10 — non-200 result_code: 422 + { message: } + no row.
  def test_create_with_non_200_result_code_returns_422
    assert_no_difference 'RdapAccessEvent.count' do
      post_event(result_code: 404)
    end

    assert_response :unprocessable_entity
    assert json_body[:message].present?
  end

  # AC11 (a) — missing required field: save returns false -> 422 + no row.
  def test_create_with_missing_field_returns_422
    assert_no_difference 'RdapAccessEvent.count' do
      post_event(domain_name: nil)
    end

    assert_response :unprocessable_entity
    assert json_body[:message].present?
  end

  # AC11 (b) — unparseable requested_at: 422 + no row.
  def test_create_with_unparseable_requested_at_returns_422
    assert_no_difference 'RdapAccessEvent.count' do
      post_event(requested_at: 'not-a-timestamp')
    end

    assert_response :unprocessable_entity
    assert json_body[:message].present?
  end

  # AC12 — Punycode name stored verbatim, no lookup.
  def test_create_with_punycode_domain_name
    post_event(domain_name: 'xn--eeau-zna.ee')
    assert_response :no_content
    assert_equal 'xn--eeau-zna.ee', RdapAccessEvent.last.domain_name
  end

  # AC12 — Unicode name stored verbatim, and a no-such-domain still succeeds (no lookup).
  def test_create_stores_domain_name_verbatim_no_lookup
    post_event(domain_name: 'õäöü.ee')
    assert_response :no_content
    assert_equal 'õäöü.ee', RdapAccessEvent.last.domain_name

    post_event(domain_name: 'no-such-domain-anywhere.ee')
    assert_response :no_content
    assert_equal 'no-such-domain-anywhere.ee', RdapAccessEvent.last.domain_name
  end

  # AC13 — forced persistence exception: 500 + { message: }. NOT a validation-false.
  def test_create_returns_500_on_save_failure
    RdapAccessEvent.stub_any_instance(:save, ->(*) { raise ActiveRecord::StatementInvalid, 'boom' }) do
      assert_no_difference 'RdapAccessEvent.count' do
        post_event
      end
    end

    assert_response :internal_server_error
    assert json_body[:message].present?
  end

  # AC14 — the save-failure exception logs an error AND increments the failure metric.
  def test_save_failure_logs_error_and_increments_counter
    logged = []
    incremented = []

    RdapAccessEvent.stub_any_instance(:save, ->(*) { raise ActiveRecord::StatementInvalid, 'boom' }) do
      NewRelic::Agent.stub(:increment_metric, ->(name, *) { incremented << name }) do
        Rails.logger.stub(:error, ->(msg = nil) { logged << msg }) do
          post_event
        end
      end
    end

    assert_response :internal_server_error
    assert_includes incremented, 'Custom/Rdap/access_event_record_failure'
    assert logged.any? { |m| m.to_s.include?('rdap_access_event') },
           'expected a technical-log error carrying the rdap_access_event marker'
  end

  # AC15 — unauthenticated request: 401 + no row.
  def test_requires_authentication_returns_401
    assert_no_difference 'RdapAccessEvent.count' do
      post '/api/v1/internal/rdap/access-events', params: valid_params
    end
    assert_response :unauthorized
  end

  # AC16 — PII gate: neither eeid_subject nor personal_id_code is stored anywhere.
  def test_create_does_not_store_eeid_subject_or_personal_id_code
    grant = rdap_privilege_grants(:with_personal_id)
    assert grant.eeid_subject.present?
    assert grant.personal_id_code.present?

    post_event(grant_id: grant.uuid)
    assert_response :no_content

    event = RdapAccessEvent.last
    values = event.attributes.values.map(&:to_s)
    assert_not_includes values, grant.eeid_subject
    assert_not_includes values, grant.personal_id_code

    columns = RdapAccessEvent.column_names
    assert_not_includes columns, 'eeid_subject'
    assert_not_includes columns, 'personal_id_code'
  end

  # AC17 — request_id is non-unique: two POSTs with the same request_id both persist.
  def test_request_id_is_not_unique
    assert_difference 'RdapAccessEvent.count', 2 do
      post_event(request_id: 'dup-123')
      post_event(request_id: 'dup-123')
    end

    assert_equal 2, RdapAccessEvent.where(request_id: 'dup-123').count
  end

  # AC17 — request_id may be omitted (nullable).
  def test_request_id_may_be_omitted
    params = valid_params.except(:request_id)
    assert_difference 'RdapAccessEvent.count', 1 do
      post '/api/v1/internal/rdap/access-events', params: params, headers: @header
    end
    assert_response :no_content
    assert_nil RdapAccessEvent.last.request_id
  end

  private

  def valid_params
    {
      grant_id: @grant.uuid,
      domain_name: 'example.ee',
      requested_at: Time.zone.now.iso8601,
      caller_ip: '192.0.2.1',
      result_code: 200,
      request_id: 'req-abc',
    }
  end

  def post_event(overrides = {})
    post '/api/v1/internal/rdap/access-events',
         params: valid_params.merge(overrides), headers: @header
  end

  def json_body
    JSON.parse(response.body, symbolize_names: true)
  end
end
