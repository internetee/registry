class AddressVersion < PaperTrail::Version
  self.table_name = :address_versions
  self.sequence_name = :address_version_id_seq
end
