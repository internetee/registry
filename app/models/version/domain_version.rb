class Version::DomainVersion < PaperTrail::Version
  extend ToCsv
  include VersionSession

  self.table_name    = :log_domains
  self.sequence_name = :log_domains_id_seq

  scope :deleted, -> { where(event: 'destroy') }

  def as_csv_row
    domain = ObjectVersionsParser.new(self).parse

    [
      domain.name,
      registrant_name(domain),
      domain.registrar,
      event,
      created_at.to_formatted_s(:db)
    ]
  end

  def self.was_contact_linked?(contact_id)
    sql = <<-SQL
      SELECT
        COUNT(*)
      FROM
        #{table_name}
      WHERE
        (children->'registrant') @> '#{contact_id}'
        OR
        (children->'admin_contacts') @> '#{contact_id}'
        OR
        (children->'tech_contacts') @> '#{contact_id}'
    SQL

    count_by_sql(sql).nonzero?
  end

  def self.contact_unlinked_more_than?(contact_id:, period:)
    sql = <<-SQL
      SELECT
        COUNT(*)
      FROM
        #{table_name}
      WHERE
        created_at < TIMESTAMP WITH TIME ZONE '#{period.ago}'
        AND (
          (children->'registrant') @> '#{contact_id}'
          OR
          (children->'admin_contacts') @> '#{contact_id}'
          OR
          (children->'tech_contacts') @> '#{contact_id}'
        )
    SQL

    count_by_sql(sql).nonzero?
  end

  def self.csv_header
    ['Name', 'Registrant', 'Registrar', 'Action', 'Created at'].freeze
  end

  private

  def registrant_name(domain)
    return domain.registrant.name if domain.registrant

    ver = Version::ContactVersion.where(item_id: domain.registrant_id).last
    contact = Contact.all_versions_for([domain.registrant_id], created_at).first

    if contact.nil? && ver
      merged_obj = ver.object_changes.to_h.transform_values(&:last)
      result = ver.object.to_h.merge(merged_obj)&.slice(*Contact&.column_names)
      contact = Contact.new(result)
    end

    contact.try(:name) || 'Deleted'
  end
end
