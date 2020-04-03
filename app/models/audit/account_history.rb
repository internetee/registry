module Audit
  class AccountHistory < BaseHistory
    self.table_name = 'audit.accounts'
  end
end
