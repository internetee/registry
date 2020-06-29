class CsyncRecord < ApplicationRecord
  belongs_to :domain, optional: false
  validates :domain, uniqueness: true
  validates :alg, :proto, :pub, :flags, :action, presence: true
  validate :validate_unique_pub_key
  validate :validate_delete_request
  after_save :update_dnskey_objects, if: proc { pushable? && !disable_requested? }
  after_save :remove_dnskeys, if: proc { pushable? && disable_requested? }

  REQUIRED_SCAN_CYCLES = 3

  def record_new_scan(result)
    obj = compose_record_meta(result)
    prefix = "CsyncRecord: #{domain.name}:"
    updated = update(obj)
    logger.info "#{prefix} cycle registered." if updated
    return if updated

    logger.info "#{prefix} reseting cycles. Reason: #{errors.full_messages.join(' .')}"
    CsyncRecord.where(domain: domain).delete_all
  end

  def compose_record_meta(result)
    result[:last_scan] = Time.zone.now
    result[:times_scanned] = persisted? && cdnskey != result[:cdnskey] ? 1 : times_scanned + 1
    result[:action] = determine_csync_intention(result[:type], result[:cdnskey])
    result.except(:type, :ns, :ns_ip)
  end

  def update_dnskey_objects
    dnskey = domain.dnskeys.new(flags: flags, protocol: proto, alg: alg, public_key: pub)
    dnskey = process_new_dnskey(dnskey)

    logger.info "Failed to add DNSKEY. #{dnskey.errors.full_messages.join('. ')}" unless dnskey
  end

  def process_new_dnskey(dnskey)
    return dnskey unless dnskey.valid?

    puts "Trying to detect DNSSEC status for domain #{domain.name}"
    current_security_level = verify_dnssec_status(domain)

    # Test if DNSSEC valid for domain beforehand
    case current_security_level
    when Dnsruby::Message::SecurityLevel.INSECURE
      dnskey.errors.add(:base, 'Pre DNSSEC does not verify (rollover)') if action == 'rollover'
      dnskey.errors.add(:base, 'Pre DNSSEC does not verify (rollover)') if action == 'deactivate'
    when Dnsruby::Message::SecurityLevel.BOGUS
      dnskey.errors.add(:base, 'Pre DNSSEC does not verify (bogus)') if action == 'rollover'
      dnskey.errors.add(:base, 'Pre DNSSEC does not verify (rollover)') if action == 'deactivate'
    when Dnsruby::Message::SecurityLevel.UNCHECKED
      dnskey.errors.add(:base, 'Pre DNSSEC does not verify (unchecked)') if action == 'rollover'
      dnskey.errors.add(:base, 'Pre DNSSEC does not verify (rollover)') if action == 'deactivate'
    end

    return dnskey if dnskey.errors.any? # if invalid security level, for example

    puts 'Pre DNSSEC changes verification succeeded successfully'

    # Test DNSSEC with new configuration
    dnskey.generate_digest
    new_security_level = verify_dnssec_status(domain, dnskey)
    puts "Security level with new DNSSEC settings: #{new_security_level}"
    if %w[rollover initialized].include? action
      unless new_security_level == Dnsruby::Message::SecurityLevel.SECURE
        dnskey.errors.add(:base, 'DNSSEC did not verify with new settings')
      end
    end

    return dnskey unless dnskey.save # if invalid security level, for example

    CsyncMailer.dnssec_updated(domain: domain).deliver_now
    notify_registrar_about_csync
    CsyncRecord.where(domain: domain).destroy_all

    true
  end

  def verify_dnssec_status(domain, dnskey = nil)
    Dnsruby::Dnssec.validation_policy = Dnsruby::Dnssec::ValidationPolicy::ALWAYS_ROOT_ONLY
    Dnsruby::Dnssec.clear_trust_anchors
    Dnsruby::Dnssec.clear_trusted_keys
    if dnskey
      Dnsruby::Dnssec.validation_policy = Dnsruby::Dnssec::ValidationPolicy::ALWAYS_LOCAL_ANCHORS_ONLY
      trusted_key = Dnsruby::RR.create(name: "#{domain.name}.", type: Dnsruby::Types.DNSKEY,
                                       flags: dnskey.flags, protocol: dnskey.protocol,
                                       algorithm: dnskey.alg,
                                       key: dnskey.public_key)
      Dnsruby::Dnssec.add_trust_anchor(trusted_key)
      trusted_ds = Dnsruby::RR.create(name: "#{domain.name}.", type: Dnsruby::Types.DS,
                                      key_tag: dnskey.ds_key_tag, algorithm: dnskey.ds_alg,
                                      digest_type: dnskey.ds_digest_type, digest: dnskey.ds_digest)
      Dnsruby::Dnssec.add_trust_anchor(trusted_ds)
    end

    inner_resolver = Dnsruby::Resolver.new(nameserver: ['8.8.8.8', '8.8.4.4'])
    inner_resolver.do_validation = true
    inner_resolver.do_caching = false
    inner_resolver.dnssec = true
    resolver = Dnsruby::Recursor.new(inner_resolver)
    resolver.dnssec = true

    resolver.query(domain.name, 'A', 'IN').security_level
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
    logger.info "CsyncJob: Removing DNSKEYs for domain '#{domain.name}'"
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

  def validate_delete_request
    return if domain.dnskeys.any?
    return if ['0 3 0 AA==', '0 3 0 0'].include? cdnskey

    errors.add(:domain, 'DNSSEC must be enabled for delete request')
  end

  def self.by_domain_name(domain_name)
    domain = Domain.find_by(name: domain_name)
    logger.info "CsyncRecord: '#{domain_name}' not in zone. Not initializing record." unless domain
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
