class Version::Billing::PriceVersion < PaperTrail::Version
  self.table_name    = :log_prices
  self.sequence_name = :log_prices_id_seq
end
