class ContactDisclosure < ActiveRecord::Base
  belongs_to :contact

  # value is true or false depending on disclosure flag
  # rules are the contents of disclose element
  class << self
    def extract_attributes(parsed_frame)
      disclosure_hash = {}
      rules = parsed_frame.css('disclose').first
      return disclosure_hash unless rules.present?
      value = rules.attributes['flag'].value
      disclosure_hash = parse_disclose_xml(rules)

      disclosure_hash.each do |k, _v|
        disclosure_hash[k] = value
      end
      disclosure_hash
    end

    private

    def parse_disclose_xml(rules)
      { int_name: parse_element_attributes_for('name', rules.children, 'int'),
        int_org_name: parse_element_attributes_for('org_name', rules.children, 'int'),
        int_addr: parse_element_attributes_for('addr', rules.children, 'int'),
        loc_name: parse_element_attributes_for('name', rules.children, 'loc'),
        loc_org_name: parse_element_attributes_for('org_name', rules.children, 'loc'),
        loc_addr: parse_element_attributes_for('addr', rules.children, 'loc'),
        phone: rules.css('voice').present?,
        email: rules.css('email').present?,
        fax: rules.css('fax').present?
      }.delete_if { |_k, v| v.nil? || v == false }
    end

    # el is the element we are looking for
    # rules are the contents of disclose element
    # value is loc/int depending on what type of el we are looking for
    def parse_element_attributes_for(el, rules, value)
      rules.css(el).each do |rule|
        next unless rule.try(:attributes) || rule.attributes['type']
        return rule.attributes['type'].value.present? if rule.attributes['type'].value == value
      end
      nil
    end
  end
end
