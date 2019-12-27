class RegistrantVerificationVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_registrant_verifications
  self.sequence_name = :log_registrant_verifications_id_seq

  scope :deleted, -> { where(event: 'destroy') }
end
