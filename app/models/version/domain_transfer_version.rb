class DomainTransferVersion < PaperTrail::Version
  self.table_name    = :log_domain_transfers
  self.sequence_name = :log_domain_transfers_id_seq
end
