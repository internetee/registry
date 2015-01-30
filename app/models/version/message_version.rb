class MessageVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_messages
  self.sequence_name = :log_messages_id_seq
end
