module Invoice::Payable
  extend ActiveSupport::Concern

  included do
    scope :unpaid, -> { where('id NOT IN (SELECT invoice_id FROM account_activities WHERE' \
                          ' invoice_id IS NOT NULL)') }
  end

  def payable?
    unpaid? && not_cancelled?
  end

  def paid?
    account_activity.present?
  end

  def receipt_date
    return unless paid?

    account_activity.created_at.to_date
  end

  def unpaid?
    !paid?
  end
end
