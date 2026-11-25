require 'test_helper'

class ReloadBalanceTaskTest < ActiveSupport::TestCase
  include ActionView::Helpers::NumberHelper
  include ActiveJob::TestHelper

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
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator')
      .to_return(status: 200, body: { everypay_link: 'http://link.test' }.to_json, headers: {})

    invoice_n = Invoice.order(number: :desc).last.number
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator')
      .to_return(status: 200, body: { invoice_number: (invoice_n + 3).to_s }.to_json, headers: {})

    stub_request(:post, 'https://eis_billing_system:3000/api/v1/e_invoice/e_invoice')
      .to_return(status: 200, body: '', headers: {})

    reload_amount = 100
    registrar = registrar_with_auto_reload_enabled_and_threshold_reached(reload_amount)

    assert_difference -> { registrar.invoices.count } do
      capture_io { run_task }
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
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator')
      .to_return(status: 200, body: { everypay_link: 'http://link.test' }.to_json, headers: {})

    invoice_n = Invoice.order(number: :desc).last.number
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator')
      .to_return(status: 200, body: { invoice_number: (invoice_n + 3).to_s }.to_json, headers: {})

    stub_request(:post, 'https://eis_billing_system:3000/api/v1/e_invoice/e_invoice')
      .to_return(status: 200, body: '', headers: {})

    registrar = registrar_with_auto_reload_enabled_and_threshold_reached

    capture_io { run_task }
    registrar.reload

    assert registrar.settings['balance_auto_reload']['pending']
  end

  def test_output
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator')
      .to_return(status: 200, body: { everypay_link: 'http://link.test' }.to_json, headers: {})

    invoice_n = Invoice.order(number: :desc).last.number
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator')
      .to_return(status: 200, body: { invoice_number: (invoice_n + 3).to_s }.to_json, headers: {})

    stub_request(:post, 'https://eis_billing_system:3000/api/v1/e_invoice/e_invoice')
      .to_return(status: 200, body: '', headers: {})

    reload_amount = 100
    registrar = registrar_with_auto_reload_enabled_and_threshold_reached(reload_amount)
    assert_equal 'Best Names', registrar.name

    assert_output %(Registrar "Best Names" got #{number_to_currency(reload_amount, unit: 'EUR')}\nInvoiced total: 1\n) do
      run_task
    end
  end

  def test_slow_e_invoice_billing_does_not_roll_back_invoice
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator')
      .to_return(status: 200, body: { everypay_link: 'http://link.test' }.to_json, headers: {})

    invoice_n = Invoice.order(number: :desc).last.number
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator')
      .to_return(status: 200, body: { invoice_number: (invoice_n + 3).to_s }.to_json, headers: {})

    e_invoice_request = stub_request(:post, 'https://eis_billing_system:3000/api/v1/e_invoice/e_invoice').to_timeout

    registrar = registrar_with_auto_reload_enabled_and_threshold_reached

    assert_difference -> { registrar.invoices.count } do
      assert_enqueued_jobs 1, only: SendEInvoiceJob do
        capture_io { run_task }
      end
    end
    assert_not_requested e_invoice_request
    assert registrar.reload.settings['balance_auto_reload']['pending']
  end

  def test_one_registrar_failure_does_not_roll_back_other_registrars
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator')
      .to_return({ status: 500, body: '<!DOCTYPE html>' },
                 { status: 200, body: { everypay_link: 'http://link.test' }.to_json })

    invoice_n = Invoice.order(number: :desc).last.number
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator')
      .to_return({ status: 200, body: { invoice_number: (invoice_n + 3).to_s }.to_json },
                 { status: 200, body: { invoice_number: (invoice_n + 4).to_s }.to_json })

    registrar_with_auto_reload_enabled_and_threshold_reached
    other_registrar = registrars(:goodnames)
    other_registrar.update!(settings: @registrar.settings)
    other_registrar.accounts.first.update!(balance: 10)

    output = nil
    assert_difference -> { Invoice.count }, 1 do
      output, = capture_io { run_task }
    end
    assert_includes output, 'balance reload failed: JSON::ParserError'
    assert_includes output, 'Invoiced total: 1'
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
