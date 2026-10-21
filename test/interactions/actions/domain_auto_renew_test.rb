require 'test_helper'
require 'support/epp/auto_renew'

class ActionsDomainAutoRenewTest < ActiveSupport::TestCase
  include EppAutoRenewSupport

  setup do
    travel_to Time.zone.now
    @feature = ENV['auto_renew_enabled']
    ENV['auto_renew_enabled'] = 'true'
    @verification = Setting.request_confirmation_on_registrant_change_enabled
    @domain = Epp::Domain.find(domains(:shop).id)
    @domain.update_columns(statuses: [DomainStatus::OK], outzone_at: nil,
                           delete_date: nil, force_delete_date: nil)
  end

  teardown do
    ENV['auto_renew_enabled'] = @feature
    Setting.request_confirmation_on_registrant_change_enabled = @verification
  end

  def test_preference_is_rolled_back_when_later_nameserver_validation_fails
    @domain.update_column(:auto_renew, false)
    nameservers = @domain.nameservers.pluck(:hostname)
    action = Actions::DomainUpdate.new(@domain, {
      registrar: @domain.registrar_id, auto_renew: { enabled: true },
      nameservers: [{ action: 'add', hostname: 'invalid nameserver' }],
    }, false)

    assert_not action.call
    assert @domain.errors.any?
    assert_nil action.auto_renew_result
    assert_not @domain.reload.auto_renew?
    assert_equal nameservers, @domain.nameservers.pluck(:hostname)
  end

  def test_successful_reversal_is_rolled_back_when_later_contact_lookup_fails
    cycle = auto_renew_cycle(@domain, charge: true)
    expiry = @domain.valid_to
    balance = cycle.account.reload.balance
    action = Actions::DomainUpdate.new(@domain, {
      registrar: @domain.registrar_id, auto_renew: { reverse_cycle_id: cycle.uuid },
      contacts: [{ action: 'add', type: 'tech', code: 'missing-contact' }],
    }, false)

    assert_no_difference 'AccountActivity.count' do
      assert_not action.call
    end
    assert_nil action.auto_renew_result
    assert_equal DomainAutoRenewal::GRACE, cycle.reload.state
    assert_nil cycle.refund_activity_id
    assert_equal balance, cycle.account.reload.balance
    assert_equal expiry, @domain.reload.valid_to
    assert @domain.auto_renew?
  end

  def test_pending_registrant_replay_does_not_repeat_reversal
    Setting.request_confirmation_on_registrant_change_enabled = true
    cycle = auto_renew_cycle(@domain, charge: true)
    action = Actions::DomainUpdate.new(@domain, {
      registrar: @domain.registrar_id, auto_renew: { reverse_cycle_id: cycle.uuid },
      registrant: { code: contacts(:william).code, verified: false },
    }, false)
    assert_difference 'AccountActivity.count', 1 do
      assert action.call
    end
    frame = @domain.reload.pending_json.fetch('frame').with_indifferent_access
    assert_not frame.key?(:auto_renew)
    assert_equal DomainAutoRenewal::REVERSED, cycle.reload.state
    assert_not @domain.auto_renew?

    assert_no_difference 'AccountActivity.count' do
      outcome = Domains::UpdateConfirm::ProcessUpdateConfirmed.run(
        domain: Domain.find(@domain.id), action: RegistrantVerification::CONFIRMED
      )
      assert outcome.valid?, outcome.errors.full_messages.join(', ')
    end
    assert_equal contacts(:william).id, @domain.reload.registrant_id
    assert_not @domain.auto_renew?
  end

  def test_create_action_rejects_reverse_and_feature_disabled_opt_in
    domain = Epp::Domain.new
    action = Actions::DomainCreate.new(domain, {
      name: 'auto-renew.test', registrar: @domain.registrar_id,
      auto_renew: { reverse_cycle_id: SecureRandom.uuid },
    })
    assert_not action.call
    assert_equal '2306', domain.errors.details[:epp_errors].first[:code]

    ENV['auto_renew_enabled'] = 'false'
    domain = Epp::Domain.new
    action = Actions::DomainCreate.new(domain, {
      name: 'auto-renew.test', registrar: @domain.registrar_id,
      auto_renew: { enabled: true },
    })
    assert_not action.call
    assert_equal '2306', domain.errors.details[:epp_errors].first[:code]
  end
end
