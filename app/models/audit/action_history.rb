module Audit
  class ActionHistory < BaseHistory
    self.table_name = 'audit.actions'
  end
end
