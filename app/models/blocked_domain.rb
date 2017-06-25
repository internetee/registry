class BlockedDomain < ActiveRecord::Base
  include Versions

  validates :name, domain_name: true, uniqueness: true

  class << self
    def by_domain name
      where(name: name)
    end
  end

  def name= val
    super SimpleIDN.to_unicode(val)
  end
end
