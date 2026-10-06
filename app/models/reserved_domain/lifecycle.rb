# Read model for the admin reservation history: one row per reservation
# (live or already ended), derived by the reserved_domain_lifecycle_rows()
# SQL function from log_reserved_domains versions plus live rows that have no
# versions yet.
#
# The table is never written by reservation write paths. It is caught up on
# admin reads (sync!), rebuilt nightly by cron and by rake tasks (rebuild!).
class ReservedDomain::Lifecycle < ApplicationRecord
  self.table_name = 'reserved_domain_lifecycles'
  self.primary_key = :id

  STATUSES = %w[active expired released_to_auction deleted removed].freeze

  END_REASON_STATUSES = {
    'reservation_expired' => 'expired',
    'released_to_auction' => 'released_to_auction',
    'admin_deleted' => 'deleted'
  }.freeze

  CSV_COLUMNS = %w[
    id domain_name status created_at created_by creation_source creation_reason
    last_changed_at last_changed_by last_source last_reason last_reason_note
    expire_at ended_at end_reason registration_recorded domain_exists
  ].freeze

  # Spreadsheet apps treat cells starting with these characters as formulas.
  CSV_FORMULA_PREFIX = /\A[=+\-@\t\r]/.freeze

  CSV_BATCH_SIZE = 1000

  # CASE equivalent of #status; the single bind is the current time.
  STATUS_SQL = <<~SQL.freeze
    CASE
      WHEN reserved_domain_lifecycles.live AND reserved_domain_lifecycles.expire_at < ? THEN 'expired'
      WHEN reserved_domain_lifecycles.live THEN 'active'
      #{END_REASON_STATUSES.map { |reason, status| "WHEN reserved_domain_lifecycles.end_reason = '#{reason}' THEN '#{status}'" }.join("\n  ")}
      ELSE 'removed'
    END
  SQL

  # Every CSV cell rendered as text by PostgreSQL, in CSV_COLUMNS order.
  # Timestamps are stored as naive UTC and exported as ISO 8601 UTC.
  CSV_SELECT_SQL = CSV_COLUMNS.map do |column|
    case column
    when 'id', 'registration_recorded' then "reserved_domain_lifecycles.#{column}::text"
    when 'status' then STATUS_SQL
    when 'domain_exists'
      '(EXISTS (SELECT 1 FROM domains d WHERE d.name = reserved_domain_lifecycles.domain_name))::text'
    when 'created_at', 'last_changed_at', 'expire_at', 'ended_at'
      %(to_char(reserved_domain_lifecycles.#{column}, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'))
    else "reserved_domain_lifecycles.#{column}"
    end
  end.join(', ').freeze

  # pg_advisory_xact_lock key serializing sync! and rebuild! across all
  # app servers and cron. Fixed arbitrary value derived from issue #2962.
  SYNC_LOCK_KEY = 2_962_000_001

  # Versions committed by long transactions can carry a created_at older
  # than the previous sync mark; re-read this much history on every sync.
  CATCH_UP_MARGIN = '10 minutes'.freeze

  MAINTAINED_COLUMNS = %w[
    domain_name created_at created_by creation_source creation_reason last_changed_at
    last_changed_by last_source last_reason last_reason_note expire_at ended_at end_reason
    registration_recorded live
  ].freeze

  ALL_IDS_SQL = <<~SQL.freeze
    SELECT item_id::bigint FROM log_reserved_domains WHERE item_type = 'ReservedDomain'
    UNION
    SELECT id::bigint FROM reserved_domains
  SQL

  # The bound is a literal (not a subquery) so the planner can use
  # index_log_reserved_domains_on_created_at.
  FRESH_IDS_SQL = <<~SQL.freeze
    SELECT item_id::bigint FROM log_reserved_domains
    WHERE item_type = 'ReservedDomain' AND created_at >= ?
    UNION
    SELECT rd.id::bigint FROM reserved_domains rd
    WHERE NOT EXISTS (SELECT 1 FROM reserved_domain_lifecycles l WHERE l.id = rd.id)
  SQL

  has_many :versions,
           -> { where(item_type: 'ReservedDomain').order(:id) },
           class_name: 'Version::ReservedDomainVersion',
           foreign_key: :item_id

  scope :with_status, lambda { |status|
    now = Time.zone.now
    case status
    when 'active' then where(live: true).where('expire_at IS NULL OR expire_at >= ?', now)
    when 'expired'
      where(live: true).where('expire_at < ?', now)
        .or(where(live: false, end_reason: 'reservation_expired'))
    when 'released_to_auction' then where(live: false, end_reason: 'released_to_auction')
    when 'deleted' then where(live: false, end_reason: 'admin_deleted')
    when 'removed'
      where(live: false).where('end_reason IS NULL OR end_reason NOT IN (?)', END_REASON_STATUSES.keys)
    else none
    end
  }

  def readonly? = true

  def status
    if live
      expire_at.present? && expire_at < Time.zone.now ? 'expired' : 'active'
    else
      END_REASON_STATUSES.fetch(end_reason, 'removed')
    end
  end

  # Catch-up used on admin reads: re-derives lifecycles touched since the
  # previous sync (minus CATCH_UP_MARGIN) and live rows missing from the
  # table. Returns false without waiting when another sync or rebuild
  # holds the lock; the caller then serves the current table contents.
  def self.sync!
    transaction do
      next false unless connection.select_value(
        sanitize_sql_array(['SELECT pg_try_advisory_xact_lock(?)', SYNC_LOCK_KEY])
      )

      since = connection.select_value(
        sanitize_sql_array(["SELECT (synced_at - CAST(? AS interval))::text FROM reserved_domain_lifecycle_syncs",
                            CATCH_UP_MARGIN])
      )
      upsert_lifecycles(since ? sanitize_sql_array([FRESH_IDS_SQL, since]) : ALL_IDS_SQL)
      true
    end
  end

  # Full re-derivation of every lifecycle (nightly cron, rake). Repairs rows
  # changed without versions and drops rows whose reservation and versions
  # are both gone. Waits for a running sync! to finish.
  def self.rebuild!
    transaction do
      connection.execute(sanitize_sql_array(['SELECT pg_advisory_xact_lock(?)', SYNC_LOCK_KEY]))
      connection.execute(<<~SQL)
        DELETE FROM reserved_domain_lifecycles l
        WHERE NOT EXISTS (SELECT 1 FROM reserved_domains rd WHERE rd.id = l.id)
          AND NOT EXISTS (SELECT 1 FROM log_reserved_domains v
                          WHERE v.item_type = 'ReservedDomain' AND v.item_id = l.id)
      SQL
      upsert_lifecycles(ALL_IDS_SQL)
    end
  end

  # now() is the transaction start, i.e. taken before reading any version,
  # so the next sync re-reads whatever is committed while this one runs.
  def self.upsert_lifecycles(ids_sql)
    connection.execute(<<~SQL)
      INSERT INTO reserved_domain_lifecycles
      SELECT * FROM reserved_domain_lifecycle_rows(ARRAY(#{ids_sql}))
      ON CONFLICT (id) DO UPDATE SET #{MAINTAINED_COLUMNS.map { |col| "#{col} = EXCLUDED.#{col}" }.join(', ')}
    SQL
    connection.execute(<<~SQL)
      INSERT INTO reserved_domain_lifecycle_syncs (id, synced_at) VALUES (1, now() AT TIME ZONE 'UTC')
      ON CONFLICT (id) DO UPDATE SET synced_at = EXCLUDED.synced_at
    SQL
  end
  private_class_method :upsert_lifecycles

  # Names among `names` that are currently registered domains.
  def self.registered_names(names)
    names = names.compact.uniq
    return Set.new if names.empty?

    Domain.where(name: names).pluck(:name).to_set
  end

  # Streamed export for the admin history page: the header line, then one
  # chunk of lines per keyset batch on id (the caller's filters apply, its
  # ORDER BY is replaced). Cells are rendered by PostgreSQL without
  # instantiating records. Passwords are never part of the table, so
  # nothing can leak here. Free-text cells (reason notes, authors) are
  # prefixed with a quote when they would be read as a formula.
  def self.csv_lines(relation)
    batches = relation.reorder(:id).limit(CSV_BATCH_SIZE)
                      .select(Arel.sql(sanitize_sql_array([CSV_SELECT_SQL, Time.zone.now])))

    Enumerator.new do |lines|
      lines << CSV.generate_line(CSV_COLUMNS)
      last_id = nil
      loop do
        batch = last_id ? batches.where('reserved_domain_lifecycles.id > ?', last_id) : batches
        rows = connection.select_rows(batch.to_sql)
        break if rows.empty?

        lines << CSV.generate { |csv| rows.each { |row| csv << row.map { |value| csv_safe(value) } } }
        break if rows.size < CSV_BATCH_SIZE

        last_id = Integer(rows.last.first)
      end
    end
  end

  def self.csv_safe(value)
    value.is_a?(String) && value.match?(CSV_FORMULA_PREFIX) ? "'#{value}" : value
  end
  private_class_method :csv_safe

  def self.ransackable_attributes(*)
    %w[
      domain_name created_at created_by creation_source creation_reason
      last_changed_at last_changed_by last_source last_reason end_reason
      ended_at expire_at registration_recorded
    ]
  end

  def self.ransackable_associations(*)
    []
  end

  def self.ransackable_scopes(*)
    %i[with_status]
  end
end
