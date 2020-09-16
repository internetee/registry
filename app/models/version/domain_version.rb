class DomainVersion < PaperTrail::Version
  include VersionSession

  self.table_name    = :log_domains
  self.sequence_name = :log_domains_id_seq

  scope :deleted, -> { where(event: 'destroy') }

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
end
