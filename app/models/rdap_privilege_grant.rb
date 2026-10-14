class RdapPrivilegeGrant < ApplicationRecord
  include Versions

  CATEGORIES = %w[police cert ria eis_internal].freeze
  STATUSES = %w[active revoked suspended].freeze

  before_create :assign_uuid

  validates :eeid_subject, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :valid_from, presence: true
  validates :full_name, presence: true
  validates :legal_basis_ref, presence: true
  validate :valid_until_after_valid_from

  # The single authoritative "active" rule (mirrors the RDAP contract §4):
  #   status == 'active' AND valid_from <= now (or null) AND (valid_until null OR valid_until > now)
  # On multiple active grants, the one with the latest valid_from wins (callers take .first).
  scope :active_for_subject, lambda { |subject|
    now = Time.zone.now
    where(eeid_subject: subject, status: 'active')
      .where('valid_from IS NULL OR valid_from <= ?', now)
      .where('valid_until IS NULL OR valid_until > ?', now)
      .order(valid_from: :desc)
  }

  def grant_id
    uuid.presence || id.to_s
  end

  # Expiry is DERIVED from valid_until at read time; it is never a stored status.
  # STATUSES stays %w[active revoked suspended] (see AC15) so the frozen RDAP
  # contract is untouched.
  def expired?
    valid_until.present? && valid_until <= Time.zone.now
  end

  # The status to present in the admin UI: an active grant whose valid_until has
  # passed reads as "expired" without any stored status change.
  def display_status
    return 'expired' if status == 'active' && expired?

    status
  end

  private

  def assign_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def valid_until_after_valid_from
    return if valid_until.blank? || valid_from.blank?
    return if valid_until > valid_from

    errors.add(:valid_until, 'must be after valid_from')
  end
end
