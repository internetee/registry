require 'test_helper'

class ReloadBalanceTaskTest < ActiveSupport::TestCase
  include ActionView::Helpers::NumberHelper

  setup do
    @registrar = registrars(:bestnames)
  end

  def test_issues_invoice_when_auto_reload_is_enabled_and_threshold_reached
    reload_amount = 100
    registrar = registrar_with_auto_reload_enabled_and_threshold_reached(reload_amount)

    assert_difference -> { registrar.invoices.count } do
      capture_io { run_task }
    end

    invoice = registrar.invoices.last
    assert_equal reload_amount, invoice.subtotal
  end

  def test_skips_issuing_invoice_when_threshold_is_not_reached
    registrar = registrar_with_auto_reload_enabled_and_threshold_not_reached

    assert_no_difference -> { registrar.invoices.count } do
      capture_io { run_task }
    end
  end

  def test_skips_issuing_invoice_when_balance_reload_is_pending
    registrar = registrar_with_auto_reload_enabled_and_threshold_reached
    registrar.settings['balance_auto_reload']['pending'] = true
    registrar.save!

    assert_no_difference -> { registrar.invoices.count } do
      capture_io { run_task }
    end
  end

  def test_marks_registrar_as_pending_balance_reload
    registrar = registrar_with_auto_reload_enabled_and_threshold_reached

    capture_io { run_task }
    registrar.reload

    assert registrar.settings['balance_auto_reload']['pending']
  end

  def test_output
    reload_amount = 100
    registrar = registrar_with_auto_reload_enabled_and_threshold_reached(reload_amount)
    assert_equal 'Best Names', registrar.name

    assert_output %(Registrar "Best Names" got #{number_to_currency(reload_amount, unit: 'EUR')}\nInvoiced total: 1\n) do
      run_task
    end
  end

  private

  def registrar_with_auto_reload_enabled_and_threshold_reached(reload_amount = 100)
    auto_reload_type = BalanceAutoReloadTypes::Threshold.new(amount: reload_amount, threshold: 10)
    @registrar.update!(settings: { balance_auto_reload: { type: auto_reload_type } })
    @registrar.accounts.first.update!(balance: 10)
    @registrar
  end

  def registrar_with_auto_reload_enabled_and_threshold_not_reached
    auto_reload_type = BalanceAutoReloadTypes::Threshold.new(amount: 100, threshold: 10)
    @registrar.update!(settings: { balance_auto_reload: { type: auto_reload_type } })
    @registrar.accounts.first.update!(balance: 11)
    @registrar
  end

  def run_task
    Rake::Task['registrars:reload_balance'].execute
  end
end