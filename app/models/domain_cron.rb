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
        DomainMailer.pending_update_expired_notification_for_new_registrant(domain.id).deliver
      end
      if domain.pending_delete? || domain.pending_delete_confirmation?
        DomainMailer.pending_delete_expired_notification(domain.id, true).deliver
      end
      domain.clean_pendings_lowlevel
      unless Rails.env.test?
        STDOUT << "#{Time.zone.now.utc} DomainCron.clean_expired_pendings: ##{domain.id} (#{domain.name})\n"
      end
      UpdateWhoisRecordJob.enqueue domain.name, 'domain'
    end
    STDOUT << "#{Time.zone.now.utc} - Successfully cancelled #{count} domain pendings\n" unless Rails.env.test?
    count
  end

  def self.start_expire_period
    Rails.logger.info('Expiring domains')

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
        DomainExpirationEmailJob.enqueue(domain_id: domain.id, run_at: send_time)
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

  #doing nothing, deprecated

  def self.start_delete_period
    # begin
    #   STDOUT << "#{Time.zone.now.utc} - Setting delete_candidate to domains\n" unless Rails.env.test?
    #
    #   d = Domain.where('delete_at <= ?', Time.zone.now)
    #   marked = 0
    #   real = 0
    #   d.each do |domain|
    #     next unless domain.delete_candidateable?
    #     real += 1
    #     domain.statuses << DomainStatus::DELETE_CANDIDATE
    #     STDOUT << "#{Time.zone.now.utc} DomainCron.start_delete_period: ##{domain.id} (#{domain.name})\n" unless Rails.env.test?
    #     ::PaperTrail.whodunnit = "cron - #{__method__}"
    #     domain.save(validate: false) and marked += 1
    #   end
    # ensure # the operator should see what was accomplished
    #   STDOUT << "#{Time.zone.now.utc} - Finished setting delete_candidate -  #{marked} out of #{real} successfully set\n" unless Rails.env.test?
    # end
    # marked
  end

  def self.destroy_delete_candidates
    STDOUT << "#{Time.zone.now.utc} - Destroying domains\n" unless Rails.env.test?

    c = 0

    domains = Domain.delete_candidates

    domains.each do |domain|
      next unless domain.delete_candidateable?

      domain.statuses << DomainStatus::DELETE_CANDIDATE

      # If domain successfully saved, add it to delete schedule
      if domain.save(validate: false)
        ::PaperTrail.whodunnit = "cron - #{__method__}"
        DomainDeleteJob.enqueue(domain.id, run_at: rand(((24*60) - (DateTime.now.hour * 60  + DateTime.now.minute))).minutes.from_now)
        STDOUT << "#{Time.zone.now.utc} Domain.destroy_delete_candidates: job added by deleteCandidate status ##{domain.id} (#{domain.name})\n" unless Rails.env.test?
        c += 1
      end
    end

    Domain.where('force_delete_at <= ?', Time.zone.now.end_of_day.utc).each do |x|
      DomainDeleteJob.enqueue(x.id, run_at: rand(((24*60) - (DateTime.now.hour * 60  + DateTime.now.minute))).minutes.from_now)
      STDOUT << "#{Time.zone.now.utc} DomainCron.destroy_delete_candidates: job added by force delete time ##{x.id} (#{x.name})\n" unless Rails.env.test?
      c += 1
    end

    STDOUT << "#{Time.zone.now.utc} - Job destroy added for #{c} domains\n" unless Rails.env.test?
  end

  # rubocop: enable Metrics/AbcSize
  # rubocop:enable Rails/FindEach
  # rubocop: enable Metrics/LineLength
  def self.destroy_with_message(domain)
    domain.destroy
    bye_bye = domain.versions.last
    domain.registrar.messages.create!(
        body: "#{I18n.t(:domain_deleted)}: #{domain.name}",
        attached_obj_id: bye_bye.id,
        attached_obj_type: bye_bye.class.to_s # DomainVersion
    )
  end

end
