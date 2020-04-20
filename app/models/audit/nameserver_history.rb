module Audit
  class NameserverHistory < BaseHistory
    self.table_name = 'audit.nameservers'

    scope :by_domain, lambda { |domain_id|
      where("new_value ->> 'domain_id' = ':x' OR old_value ->> 'domain_id' = ':x'", x: domain_id)
    }
  end
end
