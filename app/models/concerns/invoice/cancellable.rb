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
end
