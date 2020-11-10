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

  def should_notify_on_soft_force_delete?
    force_delete_scheduled? && contact_notification_sent_date.blank? &&
      force_delete_start.to_date <= Time.zone.now.to_date && force_delete_type.to_sym == :soft &&
      !statuses.include?(DomainStatus::CLIENT_HOLD)
  end

  def client_holdable?
    force_delete_scheduled? && !statuses.include?(DomainStatus::CLIENT_HOLD) &&
      force_delete_start.present? && force_delete_lte_today && force_delete_lte_valid_date
  end

  def force_delete_lte_today
    force_delete_start + Setting.expire_warning_period.days <= Time.zone.now
  end

  def force_delete_lte_valid_date
    force_delete_start + Setting.expire_warning_period.days <= valid_to
  end

  def schedule_force_delete(type: :fast_track, notify_by_email: false)
    Domain::ForceDeleteInteractor::Base.call(domain: self,
                                             type: type,
                                             notify_by_email: notify_by_email)
  end

  def clear_force_delete_data
    self.force_delete_data = nil
  end

  def cancel_force_delete
    remove_force_delete_statuses
    restore_statuses_before_force_delete
    clear_force_delete_data
    self.force_delete_date = nil
    self.force_delete_start = nil
    save(validate: false)
    registrar.notifications.create!(text: I18n.t('force_delete_cancelled', domain_name: name))
  end

  def outzone_date
    (force_delete_start || valid_to) + Setting.expire_warning_period.days
  end

  def purge_date
    (force_delete_date&.beginning_of_day || valid_to + Setting.expire_warning_period.days +
      Setting.redemption_grace_period.days)
  end

  private

  def restore_statuses_before_force_delete
    self.statuses = statuses_before_force_delete
    self.statuses_before_force_delete = nil
  end

  def remove_force_delete_statuses
    statuses.delete(DomainStatus::FORCE_DELETE)
    statuses.delete(DomainStatus::SERVER_RENEW_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_TRANSFER_PROHIBITED)
    statuses.delete(DomainStatus::CLIENT_HOLD)
  end
end
