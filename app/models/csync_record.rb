# frozen_string_literal: true

class CsyncRecord < ApplicationRecord
  belongs_to :domain, optional: false
  validates :domain, uniqueness: true
  validates :cdnskey, :action, presence: true
  validate :validate_unique_pub_key
  after_save :process_new_dnskey, if: proc { pushable? && !disable_requested? }
  after_save :remove_dnskeys, if: proc { pushable? && disable_requested? }

  SCAN_CYCLES = 3

  def record_new_scan(result, job: false)
    @log = job ? Logger.new(STDOUT) : logger
    assign_scanner_data!(result)
    prefix = "CsyncRecord: #{domain.name}:"

    if save
      @log.info "#{prefix} cycle registered."
    else
      @log.info "#{prefix} reseting cycles. Reason: #{errors.full_messages.join(' .')}"
      CsyncRecord.where(domain: domain).delete_all
    end
  end

  def assign_scanner_data!(result)
    state = result[:type]
    self.last_scan = Time.zone.now
    self.times_scanned = (persisted? && cdnskey != result[:cdnskey] ? 1 : times_scanned + 1)
    self.cdnskey = result[:cdnskey]
    self.action = initializes_dnssec?(state) ? 'initialized' : determine_csync_intention(state)
  end

  def dnskey
    key = Dnskey.new_from_csync(domain: domain, cdnskey: cdnskey)
    @log.info "DNSKEY not valid. #{key.errors.full_messages.join('. ')}." unless key.valid?

    key
  end

  def process_new_dnskey
    return unless dnssec_validates?

    if dnskey.save
      finalize_and_notify
    else
      @log.info "Failed to save DNSKEY. Errors: #{dnskey.errors.full_messages.join('. ')}"
    end
  end

  def dnssec_validates?
    return false unless dnskey.valid?
    return true if valid_security_level? && valid_security_level?(post: true)
  end

  def finalize_and_notify
    CsyncMailer.dnssec_updated(domain: domain).deliver_now
    notify_registrar_about_csync
    CsyncRecord.where(domain: domain).destroy_all
  end

  def valid_security_level?(post: false)
    valid = valid_pre_action?(domain.dnssec_security_level, action)
    valid = valid_post_action?(domain.dnssec_security_level(stubber: dnskey), action) if post

    @log.info "#{domain.name}: #{post ? 'Post' : 'Pre'} DNSSEC validation " \
      "#{valid ? 'PASSED' : 'FAILED'} for action '#{action}'"

    valid
  end

  def valid_pre_action?(security_level, action)
    case security_level
    when Dnsruby::Message::SecurityLevel.SECURE
      return true if %w[rollover deactivate].include? action
    when Dnsruby::Message::SecurityLevel.INSECURE, Dnsruby::Message::SecurityLevel.BOGUS
      return true if action == 'initialized'
    end
  end

  def valid_post_action?(security_level, action)
    secure_msg = Dnsruby::Message::SecurityLevel.SECURE
    return true if action == 'deactivate' && security_level != secure_msg
    return true if %w[rollover initialized].include?(action) && security_level == secure_msg
  end

  def pushable?
    return true if domain.dnskeys.any? || times_scanned >= SCAN_CYCLES
  end

  def disable_requested?
    ['0 3 0 AA==', '0 3 0 0'].include? dnskey.public_key
  end

  def remove_dnskeys
    @log.info "CsyncJob: Removing DNSKEYs for domain '#{domain.name}'"
    domain.dnskeys.destroy_all
    CsyncMailer.dnssec_deleted(domain: domain).deliver_now
    notify_registrar_about_csync

    destroy
  end

  def notify_registrar_about_csync
    domain.registrar.notifications.create!(text: I18n.t('notifications.texts.csync',
                                                        domain: domain.name, action: action))
  end

  def validate_unique_pub_key
    return true unless domain.dnskeys.where(public_key: dnskey.public_key).any?

    errors.add(:public_key, 'already tied this domain')
  end

  def self.by_domain_name(domain_name)
    domain = Domain.find_by(name: domain_name)
    @log.info "CsyncRecord: '#{domain_name}' not in zone. Not initializing record." unless domain
    CsyncRecord.find_or_initialize_by(domain: domain) if domain
  end

  def determine_csync_intention(scan_state)
    return unless domain.dnskeys.any? && scan_state == 'secure'

    disable_requested? ? 'deactivate' : 'rollover'
  end

  def initializes_dnssec?(scan_state)
    true if domain.dnskeys.empty? && !disable_requested? && scan_state == 'insecure'
  end
end
