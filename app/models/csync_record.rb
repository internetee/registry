class CsyncRecord < ApplicationRecord
  belongs_to :domain, optional: false
  validates :domain, uniqueness: true
  validates :alg, :proto, :pub, :flags, presence: true
  validate :validate_unique_pub_key
  after_save :update_dnskey_objects, if: proc { pushable? }

  REQUIRED_SCAN_CYCLES = 3

  def record_new_scan(result)
    obj = compose_record_meta(result)
    prefix = "CsyncRecord: #{domain.name}:"
    updated = update(obj)
    logger.info "#{prefix} cycle registered." if updated
    return if updated

    logger.info "#{prefix} not registering cycle. Reason: #{errors.full_messages.join(' .')}"
  end

  def compose_record_meta(result)
    result[:last_scan] = Time.zone.now
    result[:times_scanned] = persisted? && cdnskey != result[:cdnskey] ? 1 : times_scanned + 1

    result.except(:type, :ns, :ns_ip)
  end

  def update_dnskey_objects
    dnskey = domain.dnskeys.new(flags: flags, protocol: proto, alg: alg, public_key: pub)
    (destroy && return) if saved

    logger.info "Failed to add DNSKEY record. #{dnskey.errors.full_messages.join('. ')}"
  end

  def pushable?
    return true if domain.dnskeys.any?
    return true if times_scanned >= REQUIRED_SCAN_CYCLES

    false
  end

  def validate_unique_pub_key
    return true unless domain.dnskeys.where(public_key: pub).any?

    errors.add(:pub, 'already active for this domain')
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
end
