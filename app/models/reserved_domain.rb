class ReservedDomain < ActiveRecord::Base
  include Versions # version/reserved_domain_version.rb
  before_save :fill_empty_passwords

  def fill_empty_passwords
    return unless names
    names.each { |k, v| names[k] = SecureRandom.hex if v.blank? }
  end

  class << self
    def pw_for(domain_name)
      select("names -> '#{domain_name}' AS pw").first.try(:pw)
    end
  end
end
