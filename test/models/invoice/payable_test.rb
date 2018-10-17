require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
  end

  def test_unpaid_scope_returns_unpaid_invoices
    @invoice.account_activity = nil
    assert Invoice.unpaid.include?(@invoice), 'Should return unpaid invoice'
  end

  def test_unpaid_scope_does_not_return_paid_invoices
    assert @invoice.paid?
    assert_not Invoice.unpaid.include?(@invoice), 'Should not return paid invoice'
  end

  def test_paid_when_there_is_an_account_activity
    assert @invoice.account_activity

    assert @invoice.paid?
    assert_not @invoice.unpaid?
  end

  def test_unpaid_when_there_is_no_account_activity
    @invoice.account_activity = nil

    assert @invoice.unpaid?
    assert_not @invoice.paid?
  end

  def test_payable_when_unpaid_and_not_cancelled
    @invoice.account_activity = nil
    @invoice.cancelled_at = nil

    assert @invoice.payable?
  end

  def test_not_payable_when_already_paid
    assert @invoice.paid?
    assert_not @invoice.payable?
  end

  def test_not_payable_when_cancelled
    @invoice.cancelled_at = '2010-07-05'
    assert_not @invoice.payable?
  end

  def test_returns_receipt_date
    assert_equal Time.zone.parse('2010-07-05 10:00'), @invoice.account_activity.created_at
    assert_equal Date.parse('2010-07-05'), @invoice.receipt_date
  end
end