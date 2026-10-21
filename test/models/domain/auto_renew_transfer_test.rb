require_relative '../../interactions/domains/auto_renew/test_case'

class DomainAutoRenewTransferTest < AutoRenewTestCase
  [:transfer, :assignment].each do |transfer_path|
    [:awaiting, :grace].each do |cycle_state|
      define_method("test_#{transfer_path}_settles_#{cycle_state}_without_charging_the_new_sponsor") do
        with_feature do
          cycle = cycle_state == :grace ? renew_automatically : open_cycle
          expiry = @domain.reload.valid_to
          gaining_registrar = registrars(:goodnames)
          original_balance = @account.reload.balance
          gaining_balance = gaining_registrar.cash_account.balance
          with_feature(false) do
            assert_no_difference ['AccountActivity.count', 'Notification.count'] do
              if transfer_path == :transfer
                @domain.transfer(gaining_registrar)
              else
                @domain.registrar = gaining_registrar
                @domain.save!(validate: false)
              end
              attempt(cycle)
              Domains::AutoRenew::HandleTransfer.run!(domain: @domain)
            end
          end
          expected_state = cycle_state == :grace ? DomainAutoRenewal::COMPLETED : DomainAutoRenewal::CANCELLED
          assert_equal expected_state, cycle.reload.state
          assert cycle.closed_at.present?
          assert_equal @registrar.id, cycle.registrar_id
          assert_equal @account.id, cycle.account_id
          assert_equal gaining_registrar.id, @domain.reload.registrar_id
          assert_not @domain.auto_renew?
          assert_equal expiry, @domain.valid_to
          assert_equal original_balance, @account.reload.balance
          assert_equal gaining_balance, gaining_registrar.cash_account.balance
          assert_nil cycle.refund_activity_id
        end
      end
    end
  end

  def test_attempt_cancels_after_a_sponsor_change_even_if_callbacks_were_bypassed
    with_feature do
      cycle = open_cycle
      @domain.update_columns(registrar_id: registrars(:goodnames).id)
      assert_no_difference ['AccountActivity.count', 'Notification.count'] do
        attempt(cycle)
      end
      assert_equal DomainAutoRenewal::CANCELLED, cycle.reload.state
      assert_equal 100, @account.reload.balance
      assert_equal 100, accounts(:two).reload.balance
      assert_nil cycle.charge_activity_id
    end
  end
end
