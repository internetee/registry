class Action < ApplicationRecord
  has_paper_trail versions: { class_name: 'Version::ActionVersion' }

  belongs_to :user
  belongs_to :contact, optional: true
  has_many :subactions, class_name: 'Action',
                        foreign_key: 'bulk_action_id',
                        inverse_of: :bulk_action,
                        dependent: :destroy
  belongs_to :bulk_action, class_name: 'Action', optional: true

  validates :operation, inclusion: { in: proc { |action| action.class.valid_operations } }

  class << self
    def valid_operations
      %w[update bulk_update]
    end
  end

  def notification_key
    raise 'Action object is missing' unless bulk_action? || contact

    "contact_#{operation}".to_sym
  end

  def bulk_action?
    !!subactions.exists?
  end

  def to_non_available_contact_codes
    return [serialized_contact(contact)] unless bulk_action?

    subactions.map do |a|
      serialized_contact(a.contact)
    end
  end

  private

  def serialized_contact(contact)
    {
      code: contact.code,
      avail: 0,
      reason: 'in use',
    }
  end
end
