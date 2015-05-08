class Address < ActiveRecord::Base
  include Versions # version/address_version.rb

  LOCAL_TYPE_SHORT = 'loc'
  INTERNATIONAL_TYPE_SHORT = 'int'
  LOCAL_TYPE = 'LocalAddress'
  TYPES = [
    LOCAL_TYPE_SHORT,
    INTERNATIONAL_TYPE_SHORT
  ]

  belongs_to :contact

  def country
    Country.new(country_code)
  end

  class << self
    #    def validate_postal_info_types(parsed_frame)
    #      errors, used = [], []
    #      parsed_frame.css('postalInfo').each do |pi|
    #        attr = pi.attributes['type'].try(:value)
    #        errors << {
    #          code: 2003, msg: I18n.t('errors.messages.attr_missing', key: 'type')
    #        } and next unless attr
    #        unless TYPES.include?(attr)
    #          errors << {
    #            code: 2005,
    #            msg: I18n.t('errors.messages.invalid_type'), value: { obj: 'type', val: attr }
    #          }
    #          next
    #        end
    #        errors << {
    #          code: 2005,
    #          msg: I18n.t('errors.messages.repeating_postal_info')
    #        } and next if used.include?(attr)
    #        used << attr
    #      end; errors
    #    end

    def extract_attributes(ah)
      address_hash = {}
      ah = ah.first if ah.is_a?(Array)
      address_hash[:address_attributes] = addr_hash_from_params(ah)
      address_hash
    end

    private

    #    def local?(postal_info)
    #      return :local_address_attributes if postal_info[:type] == LOCAL_TYPE_SHORT
    #      :international_address_attributes
    #    end

    def addr_hash_from_params(addr)
      return {} if addr.nil?
      return {} unless addr[:addr].is_a?(Hash)
      { country_code: Country.new(addr[:addr][:cc]).try(:alpha2),
        city: addr[:addr][:city],
        street: pretty_street(addr[:addr][:street]), # [0],
        # street2: addr[:addr][:street][1],
        # street3: addr[:addr][:street][2],
        zip: addr[:addr][:pc]
      }.delete_if { |_k, v| v.nil? }
    end

    def pretty_street(param_street)
      return param_street.join(',') if param_street.is_a?(Array)
      param_street
    end
  end
end
