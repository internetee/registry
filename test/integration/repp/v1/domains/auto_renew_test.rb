require 'test_helper'

class ReppV1DomainsAutoRenewTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.strict_encode64("#{@user.username}:#{@user.plain_text_password}")
    @headers = { 'Authorization' => "Basic #{token}", 'Content-Type' => 'application/json' }
    @feature_enabled = ENV['auto_renew_enabled']
    ENV['auto_renew_enabled'] = 'true'
    travel_to Time.zone.local(2027, 3, 5, 12)
    ENV['shunter_default_adapter'].constantize.new.clear!
  end

  def teardown
    ENV['auto_renew_enabled'] = @feature_enabled
    super
  end

  def test_create_defaults_to_disabled_when_preference_is_omitted
    ENV['auto_renew_enabled'] = 'false'
    json = create_domain

    assert_response :ok
    assert_equal 1000, json[:code]
    refute Domain.find_by!(name: 'auto-renew.test').auto_renew?
  end

  def test_create_accepts_true_and_false_booleans
    [true, false, 'true', 'false'].each_with_index do |enabled, index|
      name = "auto-renew-#{index}.test"
      json = create_domain(name: name, auto_renew: enabled)

      assert_response :ok
      assert_equal 1000, json[:code]
      assert_equal [true, 'true'].include?(enabled), Domain.find_by!(name: name).auto_renew?
    end
  end

  def test_create_rejects_opt_in_when_feature_is_disabled
    ENV['auto_renew_enabled'] = 'false'
    json = create_domain(auto_renew: true)

    assert_response :bad_request
    assert_equal 2306, json[:code]
    refute Domain.exists?(name: 'auto-renew.test')
  end

  def test_create_rejects_invalid_booleans
    [nil, '', 'yes', '1', 0, 1, [], {}].each do |enabled|
      json = create_domain(auto_renew: enabled)

      assert_response :bad_request
      assert_equal 2005, json[:code], enabled.inspect
      refute Domain.exists?(name: 'auto-renew.test')
    end
  end

  def test_update_omitting_preference_preserves_it_and_existing_response
    @domain.update_columns(auto_renew: true)
    json = update_domain(transfer_code: 'new-transfer-code')

    assert_response :ok
    assert @domain.reload.auto_renew?
    assert_equal({ domain: { name: @domain.name } }, json[:data])
  end

  def test_update_accepts_true_and_false_without_losing_false
    [true, false, 'true', 'false'].each do |enabled|
      json = update_domain(auto_renew: enabled)

      assert_response :ok
      assert_equal [true, 'true'].include?(enabled), @domain.reload.auto_renew?
      assert_equal({ name: @domain.name }, json[:data][:domain])
      assert_equal({ enabled: @domain.auto_renew?, cycle: nil }, json[:data][:auto_renew])
      assert_nil json[:data][:reversal]
    end
  end

  def test_update_invalid_boolean_does_not_apply_other_changes
    original_code = @domain.transfer_code
    [nil, '', 'yes', '1', 0, 1, [], {}].each do |enabled|
      json = update_domain(auto_renew: enabled, transfer_code: 'must-not-change')

      assert_response :bad_request
      assert_equal 2005, json[:code], enabled.inspect
      assert_equal original_code, @domain.reload.transfer_code
    end
  end

  def test_update_feature_disabled_rejects_opt_in_and_allows_opt_out
    ENV['auto_renew_enabled'] = 'false'
    json = update_domain(auto_renew: true)
    assert_response :bad_request
    assert_equal 2306, json[:code]

    @domain.update_columns(auto_renew: true)
    update_domain(auto_renew: false)
    assert_response :ok
    refute @domain.reload.auto_renew?
  end

  def test_update_reverses_explicit_cycle_and_returns_refund
    cycle = paid_cycle
    balance = cycle.account.reload.balance
    json = update_domain(auto_renew: false, auto_renew_cycle_id: cycle.uuid)

    assert_response :ok
    assert_equal({ name: @domain.name }, json[:data][:domain])
    assert_reversal(json, cycle)
    assert_equal balance + 12, cycle.account.reload.balance
    assert_equal 'reversed', cycle.reload.state
    refute @domain.reload.auto_renew?
  end

  def test_update_cycle_id_alone_reverses_and_repeated_reversal_is_idempotent
    cycle = paid_cycle
    json = update_domain(auto_renew_cycle_id: cycle.uuid)
    assert_response :ok
    assert_reversal(json, cycle)
    balance = cycle.account.reload.balance

    assert_no_difference 'AccountActivity.count' do
      json = update_domain(auto_renew_cycle_id: cycle.uuid)
      assert_response :ok
      assert_reversal(json, cycle, repeated: true)
    end
    assert_equal balance, cycle.account.reload.balance
  end

  def test_update_reversal_errors_roll_back_other_changes
    cycle = paid_cycle
    original_code = @domain.transfer_code
    [SecureRandom.uuid, cycle.uuid].each_with_index do |cycle_id, index|
      cycle.update!(cancellation_deadline_at: Time.zone.now) if index == 1
      json = update_domain(auto_renew: false, auto_renew_cycle_id: cycle_id,
                           transfer_code: 'must-not-change')

      assert_response :bad_request
      assert_equal [2303, 2304][index], json[:code]
      assert_equal original_code, @domain.reload.transfer_code
      assert @domain.auto_renew?
      assert_nil cycle.reload.refund_activity_id
    end
  end

  def test_nested_show_returns_preference_cycle_and_public_status
    cycle = paid_cycle
    get auto_renew_path, headers: @headers
    json = response_json

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal @domain.name, json[:data][:domain]
    assert_equal({ enabled: true, cycle: cycle.as_protocol_json }, json[:data][:auto_renew])
    assert_equal ['autoRenewPeriod'], json[:data][:rgp_statuses]
  end

  def test_nested_show_without_cycle
    get auto_renew_path, headers: @headers

    assert_response :ok
    assert_equal({ enabled: false, cycle: nil }, response_json[:data][:auto_renew])
    assert_equal [], response_json[:data][:rgp_statuses]
  end

  def test_nested_update_accepts_strict_booleans
    [true, false, 'true', 'false'].each do |enabled|
      json = update_auto_renew(enabled: enabled)

      assert_response :ok
      assert_equal @domain.name, json[:data][:domain]
      assert_equal [true, 'true'].include?(enabled), @domain.reload.auto_renew?
      assert_equal @domain.auto_renew?, json[:data][:auto_renew][:enabled]
      assert_nil json[:data][:reversal]
    end
  end

  def test_nested_update_rejects_invalid_booleans
    [nil, '', 'yes', '1', 0, 1, [], {}].each do |enabled|
      json = update_auto_renew(enabled: enabled)

      assert_response :bad_request
      assert_equal 2005, json[:code], enabled.inspect
      refute @domain.reload.auto_renew?
    end
  end

  def test_nested_feature_flag_rejects_opt_in_and_allows_opt_out
    ENV['auto_renew_enabled'] = 'false'
    json = update_auto_renew(enabled: true)
    assert_response :bad_request
    assert_equal 2306, json[:code]

    @domain.update_columns(auto_renew: true)
    update_auto_renew(enabled: false)
    assert_response :ok
    refute @domain.reload.auto_renew?
  end

  def test_nested_update_requires_preference_or_cycle
    json = update_auto_renew({})

    assert_response :bad_request
    assert_equal 2003, json[:code]
  end

  def test_nested_lookup_and_domain_update_are_sponsor_scoped_even_with_transfer_code
    other = domains(:metro)
    @headers['Auth-Code'] = other.transfer_code
    get "/repp/v1/domains/#{other.name}/auto_renew", headers: @headers
    assert_response :not_found
    assert_equal 2303, response_json[:code]

    command(:put, "/repp/v1/domains/#{other.name}/auto_renew", auto_renew: { enabled: true })
    assert_response :not_found
    assert_equal 2303, response_json[:code]

    command(:put, "/repp/v1/domains/#{other.name}",
            domain: { auto_renew: true, transfer_code: other.transfer_code })
    assert_response :not_found
    assert_equal 2303, response_json[:code]
    refute other.reload.auto_renew?
  end

  def test_nested_commands_enforce_update_authorization
    @user.update!(roles: ['billing'])
    get auto_renew_path, headers: @headers
    assert_response :unauthorized
    assert_equal 2201, response_json[:code]

    json = update_auto_renew(enabled: true)
    assert_response :unauthorized
    assert_equal 2201, json[:code]
  end

  def test_nested_disable_during_grace_keeps_paid_year_without_refund
    cycle = paid_cycle
    json = update_auto_renew(enabled: false)

    assert_response :ok
    assert_nil json[:data][:reversal]
    refute @domain.reload.auto_renew?
    assert_equal cycle.renewed_expire_at, @domain.valid_to
    assert_equal 'grace', cycle.reload.state
    assert_nil cycle.refund_activity_id
  end

  def test_nested_disable_cancels_funding_retry
    cycle = create_cycle(@domain, state: DomainAutoRenewal::AWAITING_FUNDS)
    @domain.update_columns(auto_renew: true)
    update_auto_renew(enabled: false)

    assert_response :ok
    refute @domain.reload.auto_renew?
    assert_equal 'cancelled', cycle.reload.state
  end

  def test_nested_reversal_works_when_feature_is_off_and_is_idempotent
    cycle = paid_cycle
    ENV['auto_renew_enabled'] = 'false'
    balance = cycle.account.reload.balance
    json = update_auto_renew(enabled: false, cycle_id: cycle.uuid)

    assert_response :ok
    assert_reversal(json, cycle)
    assert_equal balance + 12, cycle.account.reload.balance

    assert_no_difference 'AccountActivity.count' do
      json = update_auto_renew(cycle_id: cycle.uuid)
      assert_response :ok
      assert_reversal(json, cycle, repeated: true)
    end
    assert_equal balance + 12, cycle.account.reload.balance
  end

  def test_nested_rejects_unknown_or_other_domains_cycle_without_changing_preference
    cycle = create_cycle(domains(:airport))
    @domain.update_columns(auto_renew: true)
    [SecureRandom.uuid, cycle.uuid].each do |cycle_id|
      json = update_auto_renew(enabled: false, cycle_id: cycle_id)

      assert_response :bad_request
      assert_equal 2303, json[:code]
      assert @domain.reload.auto_renew?
    end
  end

  def test_nested_rejects_reversal_at_deadline_without_refund_or_preference_change
    cycle = paid_cycle
    cycle.update!(cancellation_deadline_at: Time.zone.now)
    balance = cycle.account.reload.balance
    json = update_auto_renew(enabled: false, cycle_id: cycle.uuid)

    assert_response :bad_request
    assert_equal 2304, json[:code]
    assert @domain.reload.auto_renew?
    assert_equal cycle.renewed_expire_at, @domain.valid_to
    assert_equal balance, cycle.account.reload.balance
    assert_nil cycle.reload.refund_activity_id
  end

  def test_nested_rejects_enabling_and_reversal_together
    cycle = paid_cycle
    json = update_auto_renew(enabled: true, cycle_id: cycle.uuid)

    assert_response :bad_request
    assert_equal 2306, json[:code]
    assert_nil cycle.reload.refund_activity_id
  end

  def test_portfolio_filters_and_counts_with_multiple_historical_cycles
    grace_domain = @domain
    funding_domain = domains(:airport)
    expired_grace_domain = domains(:library)
    grace_domain.update_columns(auto_renew: true)
    funding_domain.update_columns(auto_renew: true)
    [grace_domain, funding_domain, expired_grace_domain].each do |domain|
      2.times do |index|
        create_cycle(domain, state: DomainAutoRenewal::COMPLETED,
                             original_expire_at: (index + 1).years.ago)
      end
    end
    create_cycle(grace_domain)
    create_cycle(funding_domain, state: DomainAutoRenewal::AWAITING_FUNDS)
    create_cycle(expired_grace_domain, cancellation_deadline_at: Time.zone.now)
    create_cycle(domains(:metro))

    { auto_renew_eq: [grace_domain, funding_domain], auto_renew_grace: [grace_domain],
      auto_renew_funding_retry: [funding_domain] }.each do |filter, expected|
      get '/repp/v1/domains', headers: @headers, params: { q: { filter => 'true' } }
      assert_response :ok
      assert_equal expected.map(&:name).sort, response_json[:data][:domains].sort
      assert_equal expected.size, response_json[:data][:count]

      get '/repp/v1/domains', headers: @headers,
                             params: { q: { filter => 'true' }, limit: 1, details: true, simple: true }
      assert_response :ok
      assert_equal expected.size, response_json[:data][:count]
      assert_equal 1, response_json[:data][:domains].size
      assert response_json[:data][:domains].first.key?(:auto_renew)
    end

    %i[auto_renew_grace auto_renew_funding_retry].each do |filter|
      get '/repp/v1/domains', headers: @headers, params: { q: { filter => 'false' } }
      assert_response :ok
      assert_equal @user.registrar.domains.count, response_json[:data][:count]
    end

    get '/repp/v1/domains', headers: @headers, params: { q: { auto_renew_eq: 'false' } }
    assert_response :ok
    refute_includes response_json[:data][:domains], grace_domain.name
    refute_includes response_json[:data][:domains], funding_domain.name
    assert_equal @user.registrar.domains.where(auto_renew: false).count, response_json[:data][:count]
  end

  def test_domain_info_hides_preference_from_non_sponsor_but_exposes_grace
    other = domains(:metro)
    other.update_columns(auto_renew: true)
    create_cycle(other)
    get "/repp/v1/domains/#{other.name}", headers: @headers

    assert_response :ok
    assert_equal ['autoRenewPeriod'], response_json[:data][:domain][:rgp_statuses]
    refute response_json[:data][:domain].key?(:auto_renew)
  end

  def test_enabling_after_deadline_keeps_preference_without_opening_a_cycle
    original_expiry = 20.days.ago
    @domain.update_columns(auto_renew: false, valid_to: original_expiry,
                           statuses: [DomainStatus::EXPIRED, DomainStatus::SERVER_HOLD],
                           status_notes: {}, outzone_at: 5.days.ago, delete_date: 25.days.from_now,
                           force_delete_date: nil)
    update_auto_renew(enabled: true)
    assert_response :ok
    assert_no_difference ['DomainAutoRenewal.count', 'AccountActivity.count', 'Notification.count'] do
      DomainCron.process_auto_renewals
    end

    get "/repp/v1/domains/#{@domain.name}", headers: @headers
    assert_response :ok
    data = response_json[:data][:domain]
    assert_nil data[:auto_renew][:cycle]
    assert_equal true, data[:auto_renew][:enabled]
    assert_empty data[:rgp_statuses]
    assert data[:statuses].key?(:expired)
    assert data[:statuses].key?(:serverHold)
    assert_equal original_expiry, @domain.reload.valid_to
  end

  private

  def response_json
    JSON.parse(response.body, symbolize_names: true)
  end

  def command(method, path, payload)
    assert_no_difference 'Notification.count' do
      public_send(method, path, headers: @headers, params: payload.to_json)
    end
    response_json
  end

  def create_domain(attributes = {})
    command(:post, '/repp/v1/domains', domain: {
      name: 'auto-renew.test', registrant: contacts(:john).code, period: 1, period_unit: 'y'
    }.merge(attributes))
  end

  def update_domain(attributes)
    command(:put, "/repp/v1/domains/#{@domain.name}", domain: attributes)
  end

  def update_auto_renew(attributes)
    command(:put, auto_renew_path, auto_renew: attributes)
  end

  def auto_renew_path
    "/repp/v1/domains/#{@domain.name}/auto_renew"
  end

  def create_cycle(domain, attributes = {})
    original_expire_at = attributes.fetch(:original_expire_at, 1.day.ago)
    domain.auto_renewals.create!({
      domain_name: domain.name, registrar: domain.registrar, account: domain.registrar.cash_account,
      state: DomainAutoRenewal::GRACE, original_expire_at: original_expire_at,
      renewed_expire_at: original_expire_at.advance(years: 1), attempts_count: 1,
      cancellation_deadline_at: DomainAutoRenewal.cancellation_deadline_for(original_expire_at)
    }.merge(attributes))
  end

  def paid_cycle
    charge = @user.registrar.cash_account.account_activities.create!(
      sum: -12, currency: 'EUR', activity_type: AccountActivity::RENEW,
      price: billing_prices(:renew_one_year), description: 'Automatic renewal'
    )
    cycle = create_cycle(@domain, charge_activity: charge, price: charge.price, renewed_at: Time.zone.now)
    @domain.update_columns(auto_renew: true, valid_to: cycle.renewed_expire_at,
                           statuses: [], outzone_at: nil, delete_date: nil, force_delete_date: nil)
    cycle
  end

  def assert_reversal(json, cycle, repeated: false)
    assert_equal({
      cycle_id: cycle.uuid, expire_time: @domain.reload.expire_time.iso8601,
      refund: { amount: '12.00', currency: 'EUR' }, repeated: repeated
    }, json[:data][:reversal])
    refute json[:data][:auto_renew][:enabled]
    assert_equal 'reversed', json[:data][:auto_renew][:cycle][:state]
    assert_equal cycle.original_expire_at, @domain.valid_to
  end
end
