class AccountActivityVersion < PaperTrail::Version
  self.table_name    = :log_account_activities
  self.sequence_name = :log_account_activities_id_seq
end
