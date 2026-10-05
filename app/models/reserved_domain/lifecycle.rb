# Read model over the reserved_domain_lifecycles view: one row per
# reservation (live or already ended), built from log_reserved_domains
# versions plus live rows that have no versions yet.
class ReservedDomain::Lifecycle < ApplicationRecord
  self.table_name = 'reserved_domain_lifecycles'
  self.primary_key = :id

  STATUSES = %w[active expired released_to_auction deleted removed].freeze

  CSV_COLUMNS = %w[
    id domain_name status created_at created_by creation_source creation_reason
    last_changed_at last_changed_by last_source last_reason last_reason_note
    expire_at ended_at end_reason registration_recorded domain_exists
  ].freeze

  has_many :versions,
           -> { where(item_type: 'ReservedDomain').order(:id) },
           class_name: 'Version::ReservedDomainVersion',
           foreign_key: :item_id

  def readonly? = true

  # Spreadsheet apps treat cells starting with these characters as formulas.
  CSV_FORMULA_PREFIX = /\A[=+\-@\t\r]/.freeze

  # Export for the admin history page. `find_each` needs a clean
  # primary-key order, so the caller's ORDER BY (e.g. last_changed_at)
  # is dropped explicitly. Passwords are never part of the view, so
  # nothing can leak here. Free-text cells (reason notes, authors) are
  # prefixed with a quote when they would be read as a formula.
  def self.to_csv(relation)
    CSV.generate do |csv|
      csv << CSV_COLUMNS
      relation.reorder(:id).find_each do |lifecycle|
        csv << lifecycle.attributes.values_at(*CSV_COLUMNS).map { |value| csv_safe(value) }
      end
    end
  end

  def self.csv_safe(value)
    value.is_a?(String) && value.match?(CSV_FORMULA_PREFIX) ? "'#{value}" : value
  end
  private_class_method :csv_safe

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
