class UserVersion < PaperTrail::Version
  self.table_name    = :log_users
  self.sequence_name = :log_users_id_seq
end
