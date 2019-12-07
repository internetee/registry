# Used in Registrant portal to collect registrant verifications
# Registrant postgres user can access this table directly.
class RegistrantVerification < ApplicationRecord
  has_paper_trail

  # actions
  CONFIRMED = 'confirmed'
  REJECTED  = 'rejected'

  # action types
  DOMAIN_REGISTRANT_CHANGE = 'domain_registrant_change'
  DOMAIN_DELETE = 'domain_delete'

  belongs_to :domain

  validates :verification_token, :domain, :action, :action_type, presence: true

  def domain_registrant_change_confirm!(initiator)
    self.action_type = DOMAIN_REGISTRANT_CHANGE
    self.action = CONFIRMED
    DomainUpdateConfirmJob.enqueue domain.id, CONFIRMED, initiator if save
  end

  def domain_registrant_change_reject!(initiator)
    self.action_type = DOMAIN_REGISTRANT_CHANGE
    self.action = REJECTED
    DomainUpdateConfirmJob.run domain.id, REJECTED, initiator if save
  end

  def domain_registrant_delete_confirm!(initiator)
    self.action_type = DOMAIN_DELETE
    self.action = CONFIRMED
    DomainDeleteConfirmJob.enqueue domain.id, CONFIRMED, initiator if save
  end

  def domain_registrant_delete_reject!(initiator)
    self.action_type = DOMAIN_DELETE
    self.action = REJECTED
    DomainDeleteConfirmJob.enqueue domain.id, REJECTED, initiator if save
  end
end
