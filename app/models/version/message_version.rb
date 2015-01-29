class MessageVersion < PaperTrail::Version
  self.table_name    = :log_messages
  self.sequence_name = :log_messages_id_seq
end
