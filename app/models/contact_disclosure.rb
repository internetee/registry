class ContactDisclosure < ActiveRecord::Base
  belongs_to :contact

  # value is true or false depending on disclosure flag
  # rules are the contents of disclose element
  class << self
    def default_values
      @dc = {
        name: Setting.disclosure_name,
        org_name: Setting.disclosure_org_name,
        phone: Setting.disclosure_phone,
        fax: Setting.disclosure_fax,
        email: Setting.disclosure_email,
        address: Setting.disclosure_address
      }
      @dc
    end

    def extract_attributes(parsed_frame)
      disclosure_hash = {}
      rules = parsed_frame.css('disclose').first
      return disclosure_hash unless rules.present?
      value = rules.attributes['flag'].value
      disclosure_hash = parse_disclose_xml(rules)

      disclosure_hash.each do |k, _v| # provides a correct flag to disclosure elements
        disclosure_hash[k] = value
      end
      default_values.merge(disclosure_hash)
    end

    private

    # Returns list of disclosure elements present.
    def parse_disclose_xml(rules)
      { name: parse_element_attributes_for('name', rules.children),
        org_name: parse_element_attributes_for('org_name', rules.children),
        address: parse_element_attributes_for('addr', rules.children),
        phone: rules.css('voice').present?,
        email: rules.css('email').present?,
        fax: rules.css('fax').present?
      }.delete_if { |_k, v| v.nil? || v == false }
    end

    def parse_element_attributes_for(el, rules)
      return true if rules.css(el).present?
      nil
    end
  end
end
