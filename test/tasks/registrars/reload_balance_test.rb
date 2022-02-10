require 'test_helper'

class ReloadBalanceTaskTest < ActiveSupport::TestCase
  include ActionView::Helpers::NumberHelper

  setup do
    @registrar = registrars(:bestnames)
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
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
    if Feature.billing_system_integrated?
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator").
        to_return(status: 200, body: "{\"everypay_link\":\"http://link.test\"}", headers: {})

      invoice_n = Invoice.order(number: :desc).last.number
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})

      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response").
      to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
      to_return(status: 200, body: "", headers: {})

      reload_amount = 100
      registrar = registrar_with_auto_reload_enabled_and_threshold_reached(reload_amount)

      assert_difference -> { registrar.invoices.count } do
        capture_io { run_task }
      end

      invoice = registrar.invoices.last
      assert_equal Time.zone.today, invoice.e_invoice_sent_at.to_date
    end
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
    if Feature.billing_system_integrated?
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator").
        to_return(status: 200, body: "{\"everypay_link\":\"http://link.test\"}", headers: {})

      invoice_n = Invoice.order(number: :desc).last.number
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})
        
      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})
  
      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
        to_return(status: 200, body: "", headers: {})

      registrar = registrar_with_auto_reload_enabled_and_threshold_reached

      capture_io { run_task }
      registrar.reload

      assert registrar.settings['balance_auto_reload']['pending']
    end
  end

  def test_output
    if Feature.billing_system_integrated?
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator").
        to_return(status: 200, body: "{\"everypay_link\":\"http://link.test\"}", headers: {})

      invoice_n = Invoice.order(number: :desc).last.number
      stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})

      stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response").
        to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}, {\"date\":\"#{Time.zone.now-10.minutes}\"}", headers: {})

      stub_request(:post, "http://eis_billing_system:3000/api/v1/e_invoice/e_invoice").
        to_return(status: 200, body: "", headers: {})

      reload_amount = 100
      registrar = registrar_with_auto_reload_enabled_and_threshold_reached(reload_amount)
      assert_equal 'Best Names', registrar.name

      assert_output %(Registrar "Best Names" got #{number_to_currency(reload_amount, unit: 'EUR')}\nInvoiced total: 1\n) do
        run_task
      end
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
