require 'application_system_test_case'

class RegistrarAreaSettingsBalanceAutoReloadTest < ApplicationSystemTestCase
  setup do
    @registrar = registrars(:bestnames)
    @user = users(:api_bestnames)
    sign_in @user
  end

  def test_enables_balance_auto_reload
    amount = 100
    threshold = 10
    assert_nil @registrar.settings['balance_auto_reload']

    visit registrar_account_path
    click_on 'Enable'
    fill_in 'Amount', with: amount
    fill_in 'Threshold', with: threshold
    click_button 'Save'

    assert_current_path registrar_account_path
    assert_text 'Balance Auto-Reload setting has been updated'

    # Using `number_to_currency` leads to `expected to find text "Reload 100,00 € when your balance
    # drops to 10,00 €" in "...Reload 100,00 € when your balance drops to 10,00 €...`
    assert_text 'Reload 100,00 € when your balance drops to 10,00 €'
  end

  def test_disables_balance_auto_reload
    @registrar.update!(settings: { balance_auto_reload: { type: {} } })

    visit registrar_account_path
    click_on 'Disable'

    assert_current_path registrar_account_path
    assert_text 'Balance Auto-Reload setting has been disabled'
  end

  def test_edits_balance_auto_reload
    @registrar.update!(settings: { balance_auto_reload: { type: { name: 'threshold',
                                                                  amount: 100,
                                                                  threshold: 10 } } })

    visit registrar_account_path
    within '.balance-auto-reload' do
      click_on 'Edit'
    end
    fill_in 'Amount', with: '101'
    fill_in 'Threshold', with: '11'
    click_button 'Save'

    assert_current_path registrar_account_path
    assert_text 'Balance Auto-Reload setting has been updated'
  end

  def test_form_is_pre_populated_when_editing
    amount = 100
    threshold = 10
    @registrar.update!(settings: { balance_auto_reload: { type: { name: 'threshold',
                                                                  amount: amount,
                                                                  threshold: threshold } } })

    visit edit_registrar_settings_balance_auto_reload_path

    assert_field 'Amount', with: amount
    assert_field 'Threshold', with: threshold
  end

  def test_user_of_epp_role_cannot_edit_balance_auto_reload_setting
    @user.update!(roles: [ApiUser::EPP])
    visit registrar_account_path
    assert_no_text 'Balance Auto-Reload'
  end
end