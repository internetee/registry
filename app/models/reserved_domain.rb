class ReservedDomain < ActiveRecord::Base
  include Versions # version/reserved_domain_version.rb
  before_save :fill_empty_passwords

  class << self
    def pw_for(domain_name)
      name_in_ascii = SimpleIDN.to_ascii(domain_name)
      by_domain(domain_name).first.try(:password) || by_domain(name_in_ascii).first.try(:password)
    end

    def by_domain name
      where(name: name)
    end

    def any_of_domains names
      where(name: names)
    end
  end


  def fill_empty_passwords
    self.password =  SecureRandom.hex unless self.password
  end

  def name= val
    super SimpleIDN.to_unicode(val)
  end
end
