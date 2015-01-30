class CountryVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_countries
  self.sequence_name = :log_countries_id_seq
end
