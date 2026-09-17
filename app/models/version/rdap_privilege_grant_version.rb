class Version::RdapPrivilegeGrantVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_rdap_privilege_grants
  self.sequence_name = :log_rdap_privilege_grants_id_seq
end
