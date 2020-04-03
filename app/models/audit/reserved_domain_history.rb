module Audit
  class ReservedDomainHistory < BaseHistory
    self.table_name = 'audit.reserved_domains'
  end
end
