# Used in Registrant portal to collect registrant verifications
# Registrant postgres user can access this table directly.
class RegistrantVerification < ApplicationRecord
  include Versions # version/domain_version.rb

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
    DomainUpdateConfirmJob.perform_later domain.id, CONFIRMED, initiator if save
  end

  def domain_registrant_change_reject!(initiator)
    self.action_type = DOMAIN_REGISTRANT_CHANGE
    self.action = REJECTED
    DomainUpdateConfirmJob.perform_later domain.id, REJECTED, initiator if save
  end

  def domain_registrant_delete_confirm!(initiator)
    self.action_type = DOMAIN_DELETE
    self.action = CONFIRMED
    DomainDeleteConfirmJob.perform_later domain.id, CONFIRMED, initiator if save
  end

  def domain_registrant_delete_reject!(initiator)
    self.action_type = DOMAIN_DELETE
    self.action = REJECTED
    DomainDeleteConfirmJob.perform_later domain.id, REJECTED, initiator if save
  end
end
