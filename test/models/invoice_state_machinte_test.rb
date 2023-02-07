require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @invoice = invoices(:one)
    @unpaid = invoices(:unpaid)

    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_status')
      .with(
        body: '{"invoice_number":2,"status":"paid"}'
      )
      .to_return(status: 200, body: '', headers: {})
  end

  def test_unpaid_invoice_can_be_change_status_to_paid
    assert !@unpaid.paid?

    InvoiceStateMachine.new(invoice: @unpaid, status: 'paid').call
    @unpaid.reload

    assert @unpaid.paid?
  end

  def test_no_any_errors_if_invoice_with_unpaid_status_set_again_unpaid
    assert !@unpaid.paid?

    InvoiceStateMachine.new(invoice: @unpaid, status: 'unpaid').call
    @unpaid.reload

    assert !@unpaid.paid?
    assert @unpaid.errors.empty?
  end

  def test_only_unpaid_invoice_can_be_cancelled
    assert !@unpaid.paid?

    InvoiceStateMachine.new(invoice: @unpaid, status: 'cancelled').call
    @unpaid.reload

    assert @unpaid.cancelled?

    assert @invoice.paid?
    InvoiceStateMachine.new(invoice: @invoice, status: 'cancelled').call
    @invoice.reload

    assert_equal @invoice.errors.full_messages.join, 'Inavalid state cancelled'
    assert @invoice.errors.present?
  end

  def test_cancelled_invoiced_cannot_be_unpaid
    assert !@unpaid.paid?

    InvoiceStateMachine.new(invoice: @unpaid, status: 'cancelled').call
    @unpaid.reload

    assert @unpaid.cancelled?

    InvoiceStateMachine.new(invoice: @unpaid, status: 'unpaid').call
    @unpaid.reload

    assert @unpaid.cancelled?

    assert @unpaid.errors.present?
    assert_equal @unpaid.errors.full_messages.join, 'Inavalid state unpaid'
  end

  def test_if_paid_invoice_not_have_response_from_everypay_it_can_be_unpaid_back
    assert !@unpaid.paid?

    InvoiceStateMachine.new(invoice: @unpaid, status: 'paid').call
    @unpaid.reload

    assert @unpaid.paid?
    assert_nil @unpaid.payment_orders.last.payment_reference?

    InvoiceStateMachine.new(invoice: @unpaid, status: 'unpaid').call
    @unpaid.reload

    assert !@unpaid.paid?
  end

  def test_if_paid_invoice_has_response_from_everypay_it_cannot_be_rollback
    assert !@unpaid.paid?

    InvoiceStateMachine.new(invoice: @unpaid, status: 'paid').call
    @unpaid.reload

    assert @unpaid.paid?
    payment_order = @unpaid.payment_orders.last
    payment_order.response = {}
    payment_order.response[:payment_reference] = 'responsefromeveryapy'
    payment_order.save && payment_order.reload

    assert @unpaid.payment_orders.last.payment_reference?

    InvoiceStateMachine.new(invoice: @unpaid, status: 'unpaid').call
    @unpaid.reload

    assert @unpaid.paid?
    assert @unpaid.errors.present?
    assert_equal @unpaid.errors.full_messages.join, 'Inavalid state unpaid'
  end
end
