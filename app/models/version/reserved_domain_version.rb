class Version::ReservedDomainVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_reserved_domains
  self.sequence_name = :log_reserved_domains_id_seq

  UNKNOWN_SOURCE = 'unknown'.freeze

  scope :pending_audit_backfill, lambda {
    where(domain_name: nil).or(where(source: [nil, UNKNOWN_SOURCE]))
  }

  # Fills audit meta that legacy rows (written before the audit columns
  # existed) lack. Only writes domain_name/source/reason — whodunnit,
  # object, object_changes and created_at are never touched. Idempotent:
  # returns false when there is nothing left to backfill.
  def backfill_audit!
    attrs = {}
    attrs[:domain_name] = legacy_domain_name if domain_name.nil? && legacy_domain_name.present?

    if source.nil? || source == UNKNOWN_SOURCE
      mapping = audit_backfill_mapping
      if mapping
        attrs[:source] = mapping[:source]
        attrs[:reason] = mapping[:reason] if mapping[:reason] && reason.nil?
      elsif source.nil?
        attrs[:source] = UNKNOWN_SOURCE
      end
    end

    return false if attrs.empty?

    update_columns(attrs)
    true
  end

  private

  # Whodunnit -> audit source. Only patterns we can prove; anything else
  # (e.g. a bare REPP username) returns nil and the row keeps its source.
  def audit_backfill_mapping
    case whodunnit.to_s
    when /\A#{ReservedDomain::DAILY_CLEANUP_PROCESS}/
      { source: 'expiry_job', reason: 'reservation_expired' }
    when /\A#{ReservedDomain::AVAILABILITY_CHECK_PROCESS}/
      { source: 'availability_check', reason: 'reservation_expired' }
    when /\A\d+-AdminUser:/ then { source: 'admin' }
    when /\A\d+-ApiUser:/ then { source: 'registrar' }
    when /\Aconsole-/ then { source: 'console' }
    when /\Arake-/ then { source: 'rake' }
    end
  end

  # Event-aware name for legacy rows: create takes the new name from
  # object_changes, update takes the rename when it changed the name
  # (otherwise the snapshot), destroy takes the snapshot.
  def legacy_domain_name
    changes = object_changes.is_a?(Hash) ? object_changes : {}
    snapshot = object.is_a?(Hash) ? object : {}

    case event
    when 'destroy' then snapshot['name']
    when 'create' then changes.dig('name', 1)
    else
      changes.key?('name') ? changes.dig('name', 1) : snapshot['name']
    end
  end
end
