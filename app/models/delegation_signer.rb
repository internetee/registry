class DelegationSigner < ActiveRecord::Base
  include EppErrors
  has_one :dnskeys

  validate :validate_dnskeys_uniqueness
  validate :validate_dnskeys_count


  def epp_code_map
    sg = SettingGroup.domain_validation

    {
      '2004' => [ # Parameter value range error
        [:dnskeys, :out_of_range,
          {
            min: sg.setting(Setting::DNSKEYS_MIN_COUNT).value,
            max: sg.setting(Setting::DNSKEYS_MAX_COUNT).value
          }
        ]
      ]
    }
  end

  def validate_dnskeys_count
    sg = SettingGroup.domain_validation
    min, max = sg.setting(:dnskeys_min_count).value.to_i, sg.setting(:dnskeys_max_count).value.to_i
    return if dnskeys.reject(&:marked_for_destruction?).length.between?(min, max)
    errors.add(:dnskeys, :out_of_range, { min: min, max: max })
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
