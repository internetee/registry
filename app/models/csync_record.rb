class CsyncRecord < ApplicationRecord
  belongs_to :domain, optional: false
  validates :domain, uniqueness: true
  validates :alg, :proto, :pub, :flags, :action, presence: true
  validate :validate_unique_pub_key
  after_save :process_new_dnskey, if: proc { pushable? && !disable_requested? }
  after_save :remove_dnskeys, if: proc { pushable? && disable_requested? }

  REQUIRED_SCAN_CYCLES = 3

  def record_new_scan(result, job: false)
    @log = job ? Logger.new(STDOUT) : logger
    obj = compose_record_meta(result)
    prefix = "CsyncRecord: #{domain.name}:"
    updated = update(obj)

    @log.info "#{prefix} cycle registered." if updated
    return if updated

    @log.info "#{prefix} reseting cycles. Reason: #{errors.full_messages.join(' .')}"
    CsyncRecord.where(domain: domain).delete_all
  end

  def compose_record_meta(result)
    result[:last_scan] = Time.zone.now
    result[:times_scanned] = persisted? && cdnskey != result[:cdnskey] ? 1 : times_scanned + 1
    result[:action] = determine_csync_intention(result[:type], result[:cdnskey])
    result.except(:type, :ns, :ns_ip)
  end

  def dnskey
    key = domain.dnskeys.new(flags: flags, protocol: proto, alg: alg,
                             public_key: pub, ds_digest_type: 2)

    @log.info "DNSKEY not valid. #{key.errors.full_messages.join('. ')}. Exiting" unless key.valid?

    key
  end

  def process_new_dnskey
    return unless dnskey.valid?
    return unless valid_security_level?(action)
    return unless valid_security_level?(action, post: true)

    if dnskey.save
      @log.info "Failed to save DNSKEY. Errors: #{dnskey.errors.full_messages.join('. ')}"
    else
      finalize_and_notify
    end
  end

  def finalize_and_notify
    CsyncMailer.dnssec_updated(domain: domain).deliver_now
    notify_registrar_about_csync
    CsyncRecord.where(domain: domain).destroy_all
  end

  def valid_security_level?(action, post: false)
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

    false
  end

  def valid_post_action?(security_level, action)
    secure_msg = Dnsruby::Message::SecurityLevel.SECURE
    return true if action == 'deactivate' && security_level != secure_msg
    return true if %w[rollover initialized].include?(action) && security_level == secure_msg

    false
  end

  def pushable?
    return true if domain.dnskeys.any?

    if domain.dnskeys.empty? && times_scanned >= REQUIRED_SCAN_CYCLES && !disable_requested?
      return true
    end

    false
  end

  def disable_requested?(pubkey = nil)
    pubkey ||= cdnskey
    ['0 3 0 AA==', '0 3 0 0'].include? pubkey
  end

  def remove_dnskeys
    @log.info "CsyncJob: Removing DNSKEYs for domain '#{domain.name}'"
    domain.dnskeys.destroy_all
    CsyncMailer.dnssec_deleted(domain: domain).deliver_now
    notify_registrar_about_csync

    destroy
  end

  def notify_registrar_about_csync
    registrar = domain.registrar
    registrar.notifications.create!(
      text: I18n.t('notifications.texts.csync',
                   domain: domain.name,
                   action: action)
    )
  end

  def validate_unique_pub_key
    return true unless domain.dnskeys.where(public_key: pub).any?

    errors.add(:public_key, 'already tied this domain')
  end

  def self.by_domain_name(domain_name)
    domain = Domain.find_by(name: domain_name)
    @log.info "CsyncRecord: '#{domain_name}' not in zone. Not initializing record." unless domain
    CsyncRecord.find_or_initialize_by(domain: domain) if domain
  end

  def self.clear(domain_name)
    domains = Domain.where(name: domain_name).all
    CsyncRecord.where(domain: domains).delete_all
  end

  def determine_csync_intention(type, cdnskey)
    case type
    when 'secure'
      (disable_requested?(cdnskey) ? 'deactivate' : 'rollover') if domain.dnskeys.any?
    when 'insecure'
      'initialized' unless disable_requested?(cdnskey)
    end
  end
end
