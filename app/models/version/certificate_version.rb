class CertificateVersion < PaperTrail::Version
  self.table_name    = :log_certificates
  self.sequence_name = :log_certificates_id_seq
end
