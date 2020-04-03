module Audit
  class AccountActivityHistory < BaseHistory
    self.table_name = 'audit.account_activities'
  end
end
