class NotificationVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_notifications
  self.sequence_name = :log_notifications_id_seq
end
