class ReservedDomain < ActiveRecord::Base
  include Versions # version/reserved_domain_version.rb
  before_save :fill_empty_passwords

  def fill_empty_passwords
    return unless names
    names.each { |k, v| names[k] = SecureRandom.hex if v.blank? }
  end

  class << self
    def pw_for(domain_name)
      name_in_unicode = SimpleIDN.to_ascii(domain_name)
      by_domain(domain_name).select("names -> '#{domain_name}' AS pw").first.try(:pw) ||
          by_domain(name_in_unicode).select("names -> '#{name_in_unicode}' AS pw").first.try(:pw)
    end

    def by_domain name
      where("names ? '#{name}'")
    end

    def any_of_domains names
      where("names ?| ARRAY['#{names.join("','")}']")
    end
  end
end
