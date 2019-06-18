require 'test_helper'

class RegistrarAreaSettingsBalanceAutoReloadIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @registrar = registrars(:bestnames)
    sign_in users(:api_bestnames)
  end

  def test_updates_balance_auto_reload_setting
    amount = 100
    threshold = 10
    assert_nil @registrar.settings['balance_auto_reload']

    patch registrar_settings_balance_auto_reload_path, { type: { amount: amount,
                                                                 threshold: threshold } }
    @registrar.reload

    assert_equal amount, @registrar.settings['balance_auto_reload']['type']['amount']
    assert_equal threshold, @registrar.settings['balance_auto_reload']['type']['threshold']
  end

  def test_disables_balance_auto_reload_setting
    @registrar.update!(settings: { balance_auto_reload: { amount: 'any', threshold: 'any' } })

    delete registrar_settings_balance_auto_reload_path
    @registrar.reload

    assert_nil @registrar.settings['balance_auto_reload']
  end
end