class UserVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_users
  self.sequence_name = :log_users_id_seq
end
