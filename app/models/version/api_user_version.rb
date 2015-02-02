class ApiUserVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_api_users
  self.sequence_name = :log_api_users_id_seq
end
