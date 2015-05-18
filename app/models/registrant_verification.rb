# Used in Registrant portal to collect registrant verifications
# Registrant postgres user can access this table directly.
class RegistrantVerification < ActiveRecord::Base
  validates :verification_token, :domain_name, presence: true
end
