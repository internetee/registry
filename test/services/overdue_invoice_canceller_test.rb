require 'test_helper'

class OverdueInvoiceCancellerTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
  end

  def test_default_delay
    assert_equal 30.days, OverdueInvoiceCanceller.default_delay
  end

  def test_uses_default_delay_when_not_configured
    Setting.days_to_keep_overdue_invoices_active = nil
    canceller = OverdueInvoiceCanceller.new
    assert_equal OverdueInvoiceCanceller.default_delay, canceller.delay
  end

  def test_uses_configured_delay
    Setting.days_to_keep_overdue_invoices_active = 1
    canceller = OverdueInvoiceCanceller.new
    assert_equal 1.day, canceller.delay
  end

  def test_cancels_overdue_invoices
    travel_to Time.zone.parse('2010-07-05')
    @invoice.update!(account_activity: nil, cancelled_at: nil, due_date: '2010-07-03')
    assert @invoice.cancellable?

    canceller = OverdueInvoiceCanceller.new(delay: 1.day)
    canceller.cancel
    @invoice.reload

    assert @invoice.cancelled?
  end

  def test_yields_cancelled_invoices
    travel_to Time.zone.parse('2010-07-05')
    @invoice.update!(account_activity: nil, cancelled_at: nil, due_date: '2010-07-03')
    assert @invoice.cancellable?

    canceller = OverdueInvoiceCanceller.new(delay: 1.day)

    iteration_count = 0
    canceller.cancel do |invoice|
      assert_equal @invoice, invoice
      iteration_count += 1
    end
    assert_equal 1, iteration_count
  end

  def test_keeps_not_overdue_invoices_intact
    travel_to Time.zone.parse('2010-07-05')
    @invoice.update!(account_activity: nil, cancelled_at: nil, due_date: '2010-07-04')
    assert @invoice.cancellable?

    canceller = OverdueInvoiceCanceller.new(delay: 1.day)
    canceller.cancel
    @invoice.reload

    assert @invoice.not_cancelled?
  end
end