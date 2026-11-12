# Log of confirmation emails sent for a pending registrant change or delete.
# created_at is the time the email was sent.
class DomainPendingNotification < ApplicationRecord
  REGISTRANT_CHANGE_CONFIRMATION = 'registrant_change_confirmation'.freeze
  REGISTRANT_CHANGE_NOTICE = 'registrant_change_notice'.freeze
  DELETE_CONFIRMATION = 'delete_confirmation'.freeze

  belongs_to :domain

  validates :kind, inclusion: { in: [REGISTRANT_CHANGE_CONFIRMATION, REGISTRANT_CHANGE_NOTICE,
                                     DELETE_CONFIRMATION] }
end
