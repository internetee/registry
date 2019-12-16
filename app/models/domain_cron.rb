class DomainCron

  def self.clean_expired_pendings
    STDOUT << "#{Time.zone.now.utc} - Clean expired domain pendings\n" unless Rails.env.test?

    ::PaperTrail.whodunnit = "cron - #{__method__}"
    expire_at = Setting.expire_pending_confirmation.hours.ago
    count = 0
    expired_pending_domains = Domain.where('registrant_verification_asked_at <= ?', expire_at)
    expired_pending_domains.each do |domain|
      unless domain.pending_update? || domain.pending_delete? || domain.pending_delete_confirmation?
        msg = "#{Time.zone.now.utc} - ISSUE: DOMAIN #{domain.id}: #{domain.name} IS IN EXPIRED PENDING LIST, " \
                "but no pendingDelete/pendingUpdate state present!\n"
        STDOUT << msg unless Rails.env.test?
        next
      end
      count += 1
      if domain.pending_update?
        RegistrantChangeExpiredEmailJob.enqueue(domain.id)
      end
      if domain.pending_delete? || domain.pending_delete_confirmation?
        DomainDeleteMailer.expired(domain).deliver_now
      end

      domain.preclean_pendings
      domain.clean_pendings!

      unless Rails.env.test?
        STDOUT << "#{Time.zone.now.utc} DomainCron.clean_expired_pendings: ##{domain.id} (#{domain.name})\n"
      end
      UpdateWhoisRecordJob.enqueue domain.name, 'domain'
    end
    STDOUT << "#{Time.zone.now.utc} - Successfully cancelled #{count} domain pendings\n" unless Rails.env.test?
    count
  end

  def self.start_expire_period
    ::PaperTrail.whodunnit = "cron - #{__method__}"
    domains = Domain.expired
    marked = 0
    real = 0

    domains.each do |domain|
      next unless domain.expirable?
      real += 1
      domain.set_graceful_expired
      STDOUT << "#{Time.zone.now.utc} DomainCron.start_expire_period: ##{domain.id} (#{domain.name}) #{domain.changes}\n" unless Rails.env.test?

      send_time = domain.valid_to + Setting.expiration_reminder_mail.to_i.days
      saved = domain.save(validate: false)

      if saved
        DomainExpireEmailJob.enqueue(domain.id, run_at: send_time)
        marked += 1
      end
    end

    STDOUT << "#{Time.zone.now.utc} - Successfully expired #{marked} of #{real} domains\n" unless Rails.env.test?
  end

  def self.start_redemption_grace_period
    STDOUT << "#{Time.zone.now.utc} - Setting server_hold to domains\n" unless Rails.env.test?

    ::PaperTrail.whodunnit = "cron - #{__method__}"

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
    log_prepare_client_hold

    ::PaperTrail.whodunnit = "cron - #{__method__}"

    marked = 0
    real = 0

    Domain.force_delete_scheduled.each do |domain|
      next unless domain.client_holdable?

      real += 1
      domain.statuses << DomainStatus::CLIENT_HOLD
      log_start_client_hold(domain)

      domain.save(validate: false) and marked += 1
    end

    log_end_end_client_hold(marked: marked, real: real)
    marked
  end

  def self.log_prepare_client_hold
    return if Rails.env.test?

    STDOUT << "#{Time.zone.now.utc} - Setting client_hold to domains\n"
  end

  def self.log_start_client_hold(domain)
    return if Rails.env.test?

    STDOUT << "#{Time.zone.now.utc} DomainCron.start_client_hold: ##{domain.id} (#{domain.name})"\
                "#{domain.changes}\n"
  end

  def self.log_end_end_client_hold(marked:, real:)
    return if Rails.env.test?

    STDOUT << "#{Time.zone.now.utc} - Successfully set client_hold to #{marked} of #{real} "\
              "domains\n"
  end
end
