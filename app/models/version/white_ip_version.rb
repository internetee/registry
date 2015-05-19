class WhiteIpVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_white_ips
  self.sequence_name = :log_white_ips_id_seq
end
