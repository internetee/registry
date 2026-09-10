# Registry-side store for RDAP-issued API tokens (companion to the RDAP spec
# 10-rdap-issued-api-token). RDAP owns no database, so the token state it mints
# lives here and is reached over the internal RDAP data API — exactly like
# RdapPrivilegeGrant holds the grants RDAP reads.
#
# PRIVACY / NO-SECRET INVARIANTS (mirror the RDAP contract):
#   * token_hash is the keyed HMAC-SHA-256 digest of the raw token, computed by
#     RDAP with a secret only RDAP holds. The RAW token and that secret NEVER
#     reach the registry — a leaked registry datastore alone cannot yield usable
#     tokens.
#   * The row carries NO privilege field. Authorization stays 100% grant-driven
#     (RdapPrivilegeGrant); a token only says WHO the caller is.
#   * `label` is caller-supplied free text; treat it as opaque, never as PII.
class RdapApiToken < ApplicationRecord
  TOKEN_CLASSES = %w[session machine].freeze

  validates :token_hash, presence: true, uniqueness: true
  validates :subject, presence: true
  validates :token_class, presence: true, inclusion: { in: TOKEN_CLASSES }
  validates :issued_at, presence: true
  validates :expires_at, presence: true

  # The single authoritative "active" rule (mirrors Rdap::Registry::Token#active?):
  #   not revoked AND not past expiry.
  # A revoked / expired / unknown digest all resolve to "no row" for the caller,
  # with no visible distinction (non-enumeration is a privacy property).
  scope :active_by_hash, lambda { |token_hash, now = Time.zone.now|
    where(token_hash: token_hash, revoked_at: nil)
      .where('expires_at IS NULL OR expires_at > ?', now)
  }

  scope :for_subject, ->(subject) { where(subject: subject) }

  # Idempotent single-token revoke: stamp revoked_at once; leave an already-revoked
  # row untouched so its original revocation time is preserved.
  def revoke!(at: Time.zone.now)
    return if revoked_at.present?

    update_columns(revoked_at: at)
  end

  # Record last use — last_used_at ONLY, NEVER expires_at (no sliding renewal).
  def touch_last_used!(at: Time.zone.now)
    update_columns(last_used_at: at)
  end
end
