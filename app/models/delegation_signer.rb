class DelegationSigner < ActiveRecord::Base
  include EppErrors
  has_many :dnskeys

  validate :validate_dnskeys_uniqueness

  def epp_code_map
    {}
  end

def validate_dnskeys_uniqueness
    validated = []
    list = dnskeys.reject(&:marked_for_destruction?)
    list.each do |dnskey|
      next if dnskey.public_key.blank?
      existing = list.select { |x| x.public_key == dnskey.public_key }
      next unless existing.length > 1
      validated << dnskey.public_key
      errors.add(:dnskeys, :invalid) if errors[:dnskeys].blank?
      dnskey.errors.add(:public_key, :taken)
    end
  end
end
