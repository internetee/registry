class CsyncRecord < ApplicationRecord
  belongs_to :domain, optional: false
  validates :domain, uniqueness: true
  before_validation :calculate_ds_record
  after_save :update_dnskey_objects

  REQUIRED_PERSISTANCE_IN_DAYS = 3

  def record_new_scan(fetched_cdnskey)
    self.last_scan = Time.zone.now
    self.times_scanned += 1
    self.times_scanned = 1 if persisted? && cdnskey != fetched_cdnskey
    self.cdnskey = fetched_cdnskey

    save
  end

  def update_dnskey_objects
    if pushable?
      puts "Domain DNSKEY should be updated"
    else
      puts "Domain DNSKEY SHOULD NOT be updated"
    end

    # TODO: Check that DS record is not already present
  end

  def calculate_ds_record
    self.cds = 'dummy' unless cds
    # TODO: Calculate real DS record
  end

  def pushable?
    return true if domain.dnskeys.any?
    return true if times_scanned >= REQUIRED_PERSISTANCE_IN_DAYS

    false
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
