class BankStatementVersion < PaperTrail::Version
  self.table_name    = :log_bank_statements
  self.sequence_name = :log_bank_statements_id_seq
end
