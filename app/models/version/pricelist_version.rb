class PricelistVersion < PaperTrail::Version
  self.table_name    = :log_pricelists
  self.sequence_name = :log_pricelists_id_seq
end
