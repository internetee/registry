class DomainCron
  def self.clean_expired_pendings
    Domains::ExpiredPendings::CleanAll.run!
  end

  def self.start_expire_period
    Domains::ExpirePeriod::Start.run!
  end

  def self.start_redemption_grace_period
    STDOUT << "#{Time.zone.now.utc} - Setting server_hold to domains\n" unless Rails.env.test?

    ::PaperTrail.request.whodunnit = "cron - #{__method__}"

    domains = Domain.outzone_candidates
    marked = 0
    real = 0

    domains.each do |domain|
      next unless domain.server_holdable?
      real += 1
      domain.statuses << DomainStatus::SERVER_HOLD
      STDOUT << "#{Time.zone.now.utc} DomainCron.start_redemption_grace_period: ##{domain.id} (#{domain.name}) #{domain.changes}\n" unless Rails.env.test?
      domain.save(validate: false) and marked += 1
    end

    STDOUT << "#{Time.zone.now.utc} - Successfully set server_hold to #{marked} of #{real} domains\n" unless Rails.env.test?
    marked
  end

  def self.start_client_hold
    Domains::ClientHold::SetClientHold.run!
  end
end
