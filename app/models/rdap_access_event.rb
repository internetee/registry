# Insert-only store of PRIVILEGED RDAP disclosures (RDAP spec 11).
#
# This table is itself the application event store — NOT a paper_trail audit of a
# mutable model. It therefore does NOT `include Versions` (no
# Version::RdapAccessEventVersion / log_rdap_access_events wiring exists or is
# wanted): there is nothing to "audit the mutations of", because rows are never
# mutated. Each row is a snapshot of the resolved grant taken at write time
# (organization/full_name/category/uuid only) so it survives a later grant edit,
# revoke, or delete. It MUST NEVER carry eeid_subject or personal_id_code (PII).
class RdapAccessEvent < ApplicationRecord
  validates :requested_at, presence: true
  validates :domain_name, presence: true
  validates :caller_ip, presence: true
  validates :result_code, presence: true
  validates :accessor_name, presence: true
  validates :category, presence: true
  validates :grant_ref, presence: true

  before_destroy { raise ActiveRecord::ReadOnlyRecord, 'RdapAccessEvent is insert-only' }

  # Create-only immutability: a new (unsaved) record can be inserted, but any
  # persisted row is read-only, so update!/save raise ActiveRecord::ReadOnlyRecord.
  def readonly?
    !new_record?
  end
end
