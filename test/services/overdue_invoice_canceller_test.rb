require 'test_helper'

class OverdueInvoiceCancellerTest < ActiveSupport::TestCase
  setup do
    @original_days_to_keep_overdue_invoices_active = Setting.days_to_keep_overdue_invoices_active
  end

  teardown do
    Setting.days_to_keep_overdue_invoices_active = @original_days_to_keep_overdue_invoices_active
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
    invoice = cancellable_invoice(due_date: '2010-07-03')

    canceller = OverdueInvoiceCanceller.new(delay: 1.day)
    canceller.cancel
    invoice.reload

    assert invoice.cancelled?
  end

  def test_yields_cancelled_invoices
    travel_to Time.zone.parse('2010-07-05')
    invoice = cancellable_invoice(due_date: '2010-07-03')

    canceller = OverdueInvoiceCanceller.new(delay: 1.day)

    iteration_count = 0
    canceller.cancel do |cancelled_invoice|
      assert_equal invoice, cancelled_invoice
      iteration_count += 1
    end
    assert_equal 1, iteration_count
  end

  def test_keeps_not_overdue_invoices_intact
    travel_to Time.zone.parse('2010-07-05')
    invoice = cancellable_invoice(due_date: '2010-07-04')

    canceller = OverdueInvoiceCanceller.new(delay: 1.day)
    canceller.cancel
    invoice.reload

    assert invoice.not_cancelled?
  end

  private

  def cancellable_invoice(due_date:)
    invoice = invoices(:one)
    invoice.update!(account_activity: nil, cancelled_at: nil, issue_date: due_date,
                    due_date: due_date)
    invoice
  end
end
