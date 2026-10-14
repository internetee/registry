namespace :reserved_domains do
  desc <<~TEXT.gsub("\n", "\s")
    Backfills audit metadata (domain_name, source, reason) on legacy
    log_reserved_domains rows written before the audit columns existed
  TEXT

  task backfill_audit: :environment do
    scope = Version::ReservedDomainVersion.pending_audit_backfill
    candidates = scope.count
    updated = 0

    scope.find_each(batch_size: 1000) do |version|
      updated += 1 if version.backfill_audit!
    end

    ToStdout.msg "Backfilled audit metadata on #{updated} of #{candidates} reserved domain versions"

    leftovers = scope.count
    ToStdout.msg "#{leftovers} reserved domain versions still lack provable audit metadata" if leftovers.positive?

    ReservedDomain::Lifecycle.rebuild!
    ToStdout.msg 'Rebuilt reserved domains history'
  end

  desc 'Rebuilds the admin reserved domains history from reservation versions'
  task rebuild_lifecycles: :environment do
    ReservedDomain::Lifecycle.rebuild!
    ToStdout.msg 'Rebuilt reserved domains history'
  end
end
