class ReservedDomainStatus < ApplicationRecord
  has_secure_token :access_token
  before_create :set_token_created_at

  belongs_to :reserved_domain, optional: true

  enum status: { pending: 0, paid: 1, canceled: 2, failed: 3 }

  def token_expired?
    token_created_at.nil? || token_created_at < 30.days.ago
  end

  def refresh_token
    regenerate_access_token
    update(token_created_at: Time.current)
  end

  private

  def set_token_created_at
    self.token_created_at = Time.current
  end
end
