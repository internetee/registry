class Address < ActiveRecord::Base
  LOCAL_TYPE_SHORT = 'loc'
  INTERNATIONAL_TYPE_SHORT = 'int'
  LOCAL_TYPE = 'LocalAddress'
  TYPES = [
    LOCAL_TYPE_SHORT,
    INTERNATIONAL_TYPE_SHORT
  ]

  belongs_to :contact
  belongs_to :country

  # TODO: validate inclusion of :type in LONG_TYPES or smth similar
  # validates_inclusion_of :type, in: TYPES

  class << self

    def validate_postal_info_types(parsed_frame)
      errors, used = [], []

      parsed_frame.css('postalInfo').each do |pi|
        attr = pi.attributes['type'].try(:value)
        errors << { code: 2003, msg: I18n.t('errors.messages.attr_missing', key: 'type')} and next unless attr
        if !TYPES.include?(attr)
          errors << { code: 2005, msg: I18n.t('errors.messages.invalid_type'), value: { obj: 'type', val: attr }}
          next
        end
        errors << { code: 2005, msg: I18n.t('errors.messages.repeating_postal_info') } and next if used.include?(attr)
        used << attr
      end
      errors
    end

    def extract_attributes(ah)
      address_hash = {}
      [ah].flatten.each do |pi|
        address_hash[local?(pi)] = addr_hash_from_params(pi)
      end

      address_hash
    end

    private

    def local?(postal_info)
      return :local_address_attributes if postal_info[:type] == LOCAL_TYPE_SHORT
      :international_address_attributes
    end

    def addr_hash_from_params(addr)
      return {} unless addr[:addr].is_a?(Hash)
      { name: addr[:name],
        org_name: addr[:org],
        country_id: Country.find_by(iso: addr[:addr][:cc]).try(:id),
        city: addr[:addr][:city],
        street: addr[:addr][:street][0],
        street2: addr[:addr][:street][1],
        street3: addr[:addr][:street][2],
        zip: addr[:addr][:pc]
      }.delete_if { |_k, v| v.nil? }
    end
  end
end
