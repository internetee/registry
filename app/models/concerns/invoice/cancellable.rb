module Invoice::Cancellable
  extend ActiveSupport::Concern

  included do
    scope :non_cancelled, -> { where(cancelled_at: nil) }
  end

  def can_be_cancelled?
    unless cancellable?
      errors.add(:base, :invoice_status_prohibits_operation)
      return false
    end

    true
  end

  def cancellable?
    unpaid? && not_cancelled?
  end

  def cancel
    raise 'Invoice cannot be cancelled' unless cancellable?

    update!(cancelled_at: Time.zone.now)
  end

  def cancelled?
    cancelled_at.present?
  end

  def not_cancelled?
    !cancelled?
  end

  def cancel_manualy
    account_activity = AccountActivity.find_by(invoice_id: id)
    account_activity_dup = account_activity.dup
    account_activity_dup.sum = -account_activity.sum.to_f
    account_activity_dup.save
    account_activity.update(invoice_id: nil)
    account_activity_dup.update(invoice_id: nil)
    mark_cancelled_payment_order
    account_activity.save && account_activity_dup.save
  end

  private

  def mark_cancelled_payment_order
    payment_order = payment_orders.last
    payment_order.update(notes: 'Cancelled')
  end
end
