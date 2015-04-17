class BankTransactionVersion < PaperTrail::Version
  self.table_name    = :log_bank_transactions
  self.sequence_name = :log_bank_transactions_id_seq
end
