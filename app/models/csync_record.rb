class CsyncRecord < ApplicationRecord
  belongs_to :domain, optional: false
  validates :domain, uniqueness: true
  validates :alg, :proto, :pub, :flags, presence: true
  validate :validate_unique_pub_key
  after_save :update_dnskey_objects

  REQUIRED_SCAN_CYCLES = 3

  def record_new_scan(result)
    self.last_scan = Time.zone.now
    self.times_scanned += 1
    self.times_scanned = 1 if persisted? && cdnskey != result[:cdnskey]

    # Map the key data
    self.cdnskey = result[:cdnskey]
    self.alg = result[:alg]
    self.proto = result[:proto]
    self.pub = result[:pub]
    self.flags = result[:flags]
    save
  end

  def update_dnskey_objects
    return unless pushable?

    dnskey = domain.dnskeys.new(flags: flags, protocol: proto, alg: alg, public_key: pub)
    return true if dnskey.save && destroy

    errors.add(:cdnskey, "Failed to add DNSKEY record. #{dnskey.errors.full_messages.join('. ')}")
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

  def self.by_domain_name(domain)
    domain = Domain.find_by!(name: domain)
    CsyncRecord.find_or_initialize_by(domain: domain)
  end

  def self.clear(domain_name)
    domains = Domain.where(name: domain_name).all
    CsyncRecord.where(domain: domains).delete_all
  end
end
