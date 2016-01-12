class DomainCron

  def self.clean_expired_pendings
    STDOUT << "#{Time.zone.now.utc} - Clean expired domain pendings\n" unless Rails.env.test?

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
        domain.send_mail :pending_update_expired_notification_for_new_registrant
      end
      if domain.pending_delete? || domain.pending_delete_confirmation?
        DomainMailer.pending_delete_expired_notification(domain.id, true).deliver
      end
      domain.clean_pendings!
      unless Rails.env.test?
        STDOUT << "#{Time.zone.now.utc} Domain.clean_expired_pendings: ##{domain.id} (#{domain.name})\n"
      end
    end
    STDOUT << "#{Time.zone.now.utc} - Successfully cancelled #{count} domain pendings\n" unless Rails.env.test?
    count
  end

  def self.start_expire_period
    STDOUT << "#{Time.zone.now.utc} - Expiring domains\n" unless Rails.env.test?

    domains = Domain.where('valid_to <= ?', Time.zone.now)
    domains.each do |domain|
      next unless domain.expirable?
      domain.set_graceful_expired
      DomainMailer.expiration_reminder(domain.id).deliver
      STDOUT << "#{Time.zone.now.utc} Domain.start_expire_period: ##{domain.id} (#{domain.name}) #{domain.changes}\n" unless Rails.env.test?
      domain.save
    end

    STDOUT << "#{Time.zone.now.utc} - Successfully expired #{domains.count} domains\n" unless Rails.env.test?
  end

  def self.start_redemption_grace_period
    STDOUT << "#{Time.zone.now.utc} - Setting server_hold to domains\n" unless Rails.env.test?

    d = Domain.where('outzone_at <= ?', Time.zone.now)
    d.each do |domain|
      next unless domain.server_holdable?
      domain.statuses << DomainStatus::SERVER_HOLD
      STDOUT << "#{Time.zone.now.utc} Domain.start_redemption_grace_period: ##{domain.id} (#{domain.name}) #{domain.changes}\n" unless Rails.env.test?
      domain.save
    end

    STDOUT << "#{Time.zone.now.utc} - Successfully set server_hold to #{d.count} domains\n" unless Rails.env.test?
  end

  def self.start_delete_period
    STDOUT << "#{Time.zone.now.utc} - Setting delete_candidate to domains\n" unless Rails.env.test?

    d = Domain.where('delete_at <= ?', Time.zone.now)
    d.each do |domain|
      next unless domain.delete_candidateable?
      domain.statuses << DomainStatus::DELETE_CANDIDATE
      STDOUT << "#{Time.zone.now.utc} Domain.start_delete_period: ##{domain.id} (#{domain.name}) #{domain.changes}\n" unless Rails.env.test?
      domain.save
    end

    return if Rails.env.test?
    STDOUT << "#{Time.zone.now.utc} - Successfully set delete_candidate to #{d.count} domains\n"
  end

  def self.destroy_delete_candidates
    STDOUT << "#{Time.zone.now.utc} - Destroying domains\n" unless Rails.env.test?

    c = 0
    Domain.where("statuses @> '{deleteCandidate}'::varchar[]").each do |x|
      WhoisRecord.where(domain_id: x.id).destroy_all
      destroy_with_message x
      STDOUT << "#{Time.zone.now.utc} Domain.destroy_delete_candidates: by deleteCandidate ##{x.id} (#{x.name})\n" unless Rails.env.test?

      c += 1
    end

    Domain.where('force_delete_at <= ?', Time.zone.now).each do |x|
      WhoisRecord.where(domain_id: x.id).destroy_all
      destroy_with_message x
      STDOUT << "#{Time.zone.now.utc} Domain.destroy_delete_candidates: by force delete time ##{x.id} (#{x.name})\n" unless Rails.env.test?
      c += 1
    end

    STDOUT << "#{Time.zone.now.utc} - Successfully destroyed #{c} domains\n" unless Rails.env.test?
  end

end
