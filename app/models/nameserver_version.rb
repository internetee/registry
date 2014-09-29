class NameserverVersion < PaperTrail::Version
  self.table_name = :nameserver_versions
  self.sequence_name = :nameserver_version_id_seq
end
