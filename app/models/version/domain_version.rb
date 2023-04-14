class Version::DomainVersion < PaperTrail::Version
  include VersionSession

  self.table_name    = :log_domains
  self.sequence_name = :log_domains_id_seq

  scope :deleted, -> { where(event: 'destroy') }

  def as_csv_row
    domain = ObjectVersionsParser.new(self).parse

    [
      domain.name,
      domain.registrant_info[0],
      domain.registrar,
      event,
      created_at.to_formatted_s(:db),
    ]
  end

  def self.ransackable_associations(*)
    authorizable_ransackable_associations
  end

  def self.ransackable_attributes(*)
    authorizable_ransackable_attributes
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
    ['Name', 'Registrant', 'Registrar', 'Action', 'Created at']
  end
end
