module Audit
  class DnskeyHistory < BaseHistory
    self.table_name = 'audit.dnskeys'

    scope :by_domain, lambda { |domain_id|
      where("new_value ->> 'domain_id' = ':x' OR old_value ->> 'domain_id' = ':x'", x: domain_id)
    }
  end
end
