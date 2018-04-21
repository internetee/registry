module Concerns::Domain::ForceDelete
  extend ActiveSupport::Concern

  def force_delete_scheduled?
    statuses.include?(DomainStatus::FORCE_DELETE)
  end

  def schedule_force_delete
    statuses << DomainStatus::FORCE_DELETE
    statuses << DomainStatus::SERVER_RENEW_PROHIBITED
    statuses << DomainStatus::SERVER_TRANSFER_PROHIBITED
    statuses << DomainStatus::SERVER_UPDATE_PROHIBITED
    statuses << DomainStatus::PENDING_DELETE

    if (statuses & [DomainStatus::SERVER_HOLD, DomainStatus::CLIENT_HOLD]).empty?
      statuses << DomainStatus::SERVER_MANUAL_INZONE
    end

    self.force_delete_at = (Time.zone.now + (Setting.redemption_grace_period.days + 1.day)).utc
                             .beginning_of_day
    stop_all_pending_actions
    save(validate: false)
  end

  def cancel_force_delete
    statuses.delete(DomainStatus::FORCE_DELETE)
    statuses.delete(DomainStatus::SERVER_RENEW_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_TRANSFER_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_UPDATE_PROHIBITED)
    statuses.delete(DomainStatus::PENDING_DELETE)
    statuses.delete(DomainStatus::SERVER_MANUAL_INZONE)

    self.force_delete_at = nil
    save(validate: false)
  end

  private

  def stop_all_pending_actions
    statuses.delete(DomainStatus::CLIENT_DELETE_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_DELETE_PROHIBITED)
    statuses.delete(DomainStatus::PENDING_UPDATE)
    statuses.delete(DomainStatus::PENDING_TRANSFER)
    statuses.delete(DomainStatus::PENDING_RENEW)
    statuses.delete(DomainStatus::PENDING_CREATE)
  end
end
