require 'test_helper'

class AccountActivityTest < ActiveSupport::TestCase
  setup do
    @account_activity = account_activities(:one)
  end

  def test_fixture_is_valid
    assert @account_activity.valid?
  end

  def test_refund_is_valid_and_available_for_selection
    account = accounts(:cash)
    balance = account.balance
    refund = account.account_activities.create!(sum: 10, currency: account.currency,
                                                activity_type: AccountActivity::REFUND)

    assert refund.valid?
    assert_equal balance + 10, account.reload.balance
    assert_equal balance + 10, refund.reload.new_balance
    %i[en et].each do |locale|
      I18n.with_locale(locale) do
        assert I18n.exists?('refund', locale)
        assert_includes AccountActivity.types_for_select, [I18n.t('refund'), AccountActivity::REFUND]
      end
    end
  end

  def test_balance_updates_do_not_overwrite_changes_from_stale_account_instances
    debit_account = Account.find(accounts(:cash).id)
    credit_account = Account.find(debit_account.id)
    balance = debit_account.balance

    debit = debit_account.account_activities.create!(sum: -12, currency: 'EUR',
                                                    activity_type: AccountActivity::RENEW)
    credit = credit_account.account_activities.create!(sum: 25, currency: 'EUR',
                                                      activity_type: AccountActivity::ADD_CREDIT)

    assert_equal balance - 12, debit.reload.new_balance
    assert_equal balance + 13, credit.reload.new_balance
    assert_equal balance + 13, debit_account.reload.balance
  end

  def test_account_save_failure_raises_and_rolls_back_activity
    account = accounts(:cash)
    balance = account.balance
    activity = account.account_activities.build(sum: 10, currency: account.currency,
                                               activity_type: AccountActivity::REFUND)

    account.stub(:save!, -> { raise ActiveRecord::RecordInvalid.new(account) }) do
      assert_no_difference('AccountActivity.count') do
        assert_raises(ActiveRecord::RecordInvalid) { activity.save! }
      end
    end

    assert_equal balance, account.reload.balance
  end
end
