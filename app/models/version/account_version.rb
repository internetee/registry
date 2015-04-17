class AccountVersion < PaperTrail::Version
  self.table_name    = :log_accounts
  self.sequence_name = :log_accounts_id_seq
end
