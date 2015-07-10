class ReservedDomain < ActiveRecord::Base
  include Versions # version/reserved_domain_version.rb

  class << self
    def pw_for(domain_name)
      select("names -> '#{domain_name}' AS pw").first.try(:pw)
    end
  end
end
