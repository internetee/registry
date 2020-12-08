require 'test_helper'

class ReppV1RetainedDomainsTest < ActionDispatch::IntegrationTest
  # Uses magical fixtures, will fail once fixtures inside are changed:
  # test/fixtures/blocked_domains.yml
  # test/fixtures/reserved_domains.yml

  def test_get_index
    get repp_v1_retained_domains_path
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert response_json[:count] == 3

    expected_objects = [{ name: 'blocked.test',
                          status: 'blocked',
                          punycode_name: 'blocked.test' },
                        { name: 'blockedäöüõ.test',
                          status: 'blocked',
                          punycode_name: 'xn--blocked-cxa7mj0e.test' },
                        { name: 'reserved.test',
                          status: 'reserved',
                          punycode_name: 'reserved.test' }]

    assert_equal response_json[:domains], expected_objects
  end

  def test_get_index_with_type_parameter
    get repp_v1_retained_domains_path({ 'type' => 'reserved' })
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert response_json[:count] == 1

    expected_objects = [{ name: 'reserved.test',
                          status: 'reserved',
                          punycode_name: 'reserved.test' }]

    assert_equal response_json[:domains], expected_objects
  end

  def test_get_index_disputed_type
    dispute = Dispute.new(domain_name: 'disputed.test', starts_at: Time.zone.today, password: 'disputepw')
    dispute.save

    get repp_v1_retained_domains_path({ 'type' => 'disputed' })
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert response_json[:count] == 1

    expected_objects = [{ name: 'disputed.test',
                          status: 'disputed',
                          punycode_name: 'disputed.test' }]

    assert_equal response_json[:domains], expected_objects
  end

  # A disputed domain can be also reserved, and according
  # to business rules it should appear on the list twice.
  def test_domain_can_appear_twice_if_it_is_disputed_and_reserved
    dispute = Dispute.new(domain_name: 'reserved.test', starts_at: Time.zone.today, password: 'disputepw')
    dispute.save

    get repp_v1_retained_domains_path
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert response_json[:count] == 4

    expected_objects = [{ name: 'blocked.test',
                          status: 'blocked',
                          punycode_name: 'blocked.test' },
                        { name: 'blockedäöüõ.test',
                          status: 'blocked',
                          punycode_name: 'xn--blocked-cxa7mj0e.test' },
                        { name: 'reserved.test',
                          status: 'reserved',
                          punycode_name: 'reserved.test' },
                        { name: 'reserved.test',
                          status: 'disputed',
                          punycode_name: 'reserved.test' }]

    assert_equal response_json[:domains].to_set, expected_objects.to_set
  end

  def test_etags_cache
    get repp_v1_retained_domains_path({ 'type' => 'reserved' })
    etag = response.headers['ETag']

    get repp_v1_retained_domains_path({ 'type' => 'reserved' }),
        headers: { 'If-None-Match' => etag }

    assert_equal response.status, 304
    assert_equal response.body, ''
  end

  def test_etags_cache_valid_for_type_only
    get repp_v1_retained_domains_path({ 'type' => 'blocked' })
    etag = response.headers['ETag']

    get repp_v1_retained_domains_path, headers: { 'If-None-Match' => etag }

    assert_equal response.status, 200
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert response_json[:count] == 3
  end

  def test_cors_preflight
    process :options, repp_v1_retained_domains_path, headers: { 'Origin' => 'https://example.com' }

    assert_equal('https://example.com', response.headers['Access-Control-Allow-Origin'])
    assert_equal('POST, GET, PUT, PATCH, DELETE, OPTIONS',
                 response.headers['Access-Control-Allow-Methods'])
    assert_equal('Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email, ' \
                 'X-User-Token, X-User-Email',
               response.headers['Access-Control-Allow-Headers'])
    assert_equal('3600', response.headers['Access-Control-Max-Age'])
    assert_equal('', response.body)
  end
end
