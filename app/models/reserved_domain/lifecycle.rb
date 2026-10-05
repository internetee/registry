# Read model over the reserved_domain_lifecycles view: one row per
# reservation (live or already ended), built from log_reserved_domains
# versions plus live rows that have no versions yet.
class ReservedDomain::Lifecycle < ApplicationRecord
  self.table_name = 'reserved_domain_lifecycles'
  self.primary_key = :id

  STATUSES = %w[active expired released_to_auction deleted removed].freeze

  has_many :versions,
           -> { where(item_type: 'ReservedDomain').order(:id) },
           class_name: 'Version::ReservedDomainVersion',
           foreign_key: :item_id

  def readonly? = true

  def self.ransackable_attributes(*)
    %w[
      domain_name status created_at created_by creation_source creation_reason
      last_changed_at last_changed_by last_source last_reason end_reason
      ended_at expire_at registration_recorded domain_exists
    ]
  end

  def self.ransackable_associations(*)
    []
  end
end
