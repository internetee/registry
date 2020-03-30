module Audit
  class BlockedDomain < Base
    self.table_name = 'audit.blocked_domains'
  end
end
