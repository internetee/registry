class DnskeyVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_dnskeys
  self.sequence_name = :log_dnskeys_id_seq
end
