class ReservedDomain < ActiveRecord::Base
  include Versions # version/reserved_domain_version.rb
  before_save :fill_empty_passwords

  validates :name, domain_name: true, uniqueness: true

  class << self
    def pw_for(domain_name)
      name_in_ascii = SimpleIDN.to_ascii(domain_name)
      by_domain(domain_name).first.try(:password) || by_domain(name_in_ascii).first.try(:password)
    end

    def by_domain name
      where(name: name)
    end

    def new_password_for name
      record = by_domain(name).first
      return unless record

      record.regenerate_password
      record.save
    end
  end

  def name= val
    super SimpleIDN.to_unicode(val)
  end

  def fill_empty_passwords
    regenerate_password if self.password.blank?
  end

  def regenerate_password
    self.password = SecureRandom.hex
  end

  def updatable?
    !Dispute.exists?(domain_name: name)
  end
end
