module Audit
  class NotificationHistory < BaseHistory
    self.table_name = 'audit.notifications'
  end
end
