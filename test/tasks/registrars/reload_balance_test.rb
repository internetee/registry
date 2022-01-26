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

  def test_issues_invoice_when_auto_reload_is_enabled_and_threshold_reached
    invoice_n = Invoice.order(number: :desc).last.number
    stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
      with(
        headers: {
              'Accept'=>'Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw==',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer foobar',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Ruby'
            }).
      to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})
    reload_amount = 100
    registrar = registrar_with_auto_reload_enabled_and_threshold_reached(reload_amount)

    assert_difference -> { registrar.invoices.count } do
      capture_io { run_task }
    end

    invoice = registrar.invoices.last
    assert_equal Time.zone.today, invoice.e_invoice_sent_at.to_date
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
    invoice_n = Invoice.order(number: :desc).last.number
    stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
      with(
        headers: {
              'Accept'=>'Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw==',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer foobar',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Ruby'
            }).
      to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})
    registrar = registrar_with_auto_reload_enabled_and_threshold_reached

    capture_io { run_task }
    registrar.reload

    assert registrar.settings['balance_auto_reload']['pending']
  end

  def test_output
    invoice_n = Invoice.order(number: :desc).last.number
    stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
      with(
        headers: {
              'Accept'=>'Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw==',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer foobar',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Ruby'
            }).
      to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})
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
