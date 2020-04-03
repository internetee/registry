module Audit
  class UserHistory < BaseHistory
    self.table_name = 'audit.users'
  end
end
