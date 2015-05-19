# Used in Registrant portal to collect registrant verifications
# Registrant postgres user can access this table directly.
class RegistrantVerification < ActiveRecord::Base
  # actions
  CONFIRMED = 'confirmed'
  REJECTED  = 'rejected'
  
  # action types
  DOMAIN_REGISTRANT_CHANGE = 'domain_registrant_change'
  DOMAIN_DELETE = 'domain_delete'

  belongs_to :domain

  validates :verification_token, :domain_name, :domain, :action, :action_type, presence: true
  validates :domain, uniqueness: { scope: [:domain_id, :verification_token] }

  def domain_registrant_change_confirm!
    self.action_type = DOMAIN_REGISTRANT_CHANGE
    self.action = CONFIRMED
    save
  end

  def domain_registrant_change_reject!
    self.action_type = DOMAIN_REGISTRANT_CHANGE
    self.action = REJECTED
    save
  end
end
