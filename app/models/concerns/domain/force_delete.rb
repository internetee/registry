module Concerns::Domain::ForceDelete # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern

  included do
    store_accessor :force_delete_data,
                   :force_delete_type,
                   :contact_notification_sent_date,
                   :template_name

    scope :notification_not_sent,
          lambda {
            where("(force_delete_data->>'contact_notification_sent_date') is null")
          }
  end

  class_methods do
    def force_delete_scheduled
      where('force_delete_start <= ?', Time.zone.now)
    end
  end

  def notification_template
    if contact_emails_verification_failed.present?
      'invalid_email'
    elsif registrant.org?
      'legal_person'
    else
      'private_person'
    end
  end

  def force_delete_scheduled?
    statuses.include?(DomainStatus::FORCE_DELETE)
  end

  def schedule_force_delete(type: :fast_track, notify_by_email: false)
    ForceDeleteInteraction::SetForceDelete.run(domain: self,
                                               type: type,
                                               notify_by_email: notify_by_email)
  end

  def cancel_force_delete
    CancelForceDeleteInteraction::CancelForceDelete.run(domain: self)
  end

  def outzone_date
    (force_delete_start || valid_to) + Setting.expire_warning_period.days
  end

  def purge_date
    (force_delete_date&.beginning_of_day || valid_to + Setting.expire_warning_period.days +
      Setting.redemption_grace_period.days)
  end
end
