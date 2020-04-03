module Audit
  class BlockedDomainHistory < BaseHistory
    self.table_name = 'audit.blocked_domains'
  end
end
