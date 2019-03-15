require 'test_helper'

class CancellableInvoiceTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
  end

  def test_non_cancelled_scope_returns_non_cancelled_invoices
    @invoice.update!(cancelled_at: nil)
    assert Invoice.non_cancelled.include?(@invoice), 'Should return cancelled invoice'
  end

  def test_non_cancelled_scope_does_not_return_cancelled_invoices
    @invoice.update!(cancelled_at: '2010-07-05')
    assert_not Invoice.non_cancelled.include?(@invoice), 'Should not return cancelled invoice'
  end

  def test_cancellable_when_unpaid_and_not_yet_cancelled
    @invoice.account_activity = nil
    @invoice.cancelled_at = nil
    assert @invoice.cancellable?
  end

  def test_not_cancellable_when_paid
    assert @invoice.paid?
    assert_not @invoice.cancellable?
  end

  def test_not_cancellable_when_already_cancelled
    @invoice.cancelled_at = '2010-07-05'
    assert_not @invoice.cancellable?
  end

  def test_cancels_an_invoice
    travel_to Time.zone.parse('2010-07-05 08:00')
    @invoice.account_activity = nil
    assert @invoice.cancellable?
    assert_nil @invoice.cancelled_at

    @invoice.cancel
    @invoice.reload

    assert @invoice.cancelled?
    assert_equal Time.zone.parse('2010-07-05 08:00'), @invoice.cancelled_at
  end

  def test_throws_an_exception_when_trying_to_cancel_already_cancelled_invoice
    @invoice.cancelled_at = '2010-07-05'

    e = assert_raise do
      @invoice.cancel
    end
    assert_equal 'Invoice cannot be cancelled', e.message
  end

  def test_not_cancelled
    @invoice.cancelled_at = nil

    assert @invoice.not_cancelled?
    assert_not @invoice.cancelled?
  end

  def test_cancelled
    @invoice.cancelled_at = '2010-07-05'

    assert @invoice.cancelled?
    assert_not @invoice.not_cancelled?
  end
end