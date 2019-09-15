module Concerns::Domain::ForceDelete
  extend ActiveSupport::Concern

  def force_delete_scheduled?
    statuses.include?(DomainStatus::FORCE_DELETE)
  end

  def schedule_force_delete
    if discarded?
      raise StandardError, 'Force delete procedure cannot be scheduled while a domain is discarded'
    end

    preserve_current_statuses_for_force_delete
    add_force_delete_statuses
    self.force_delete_date = Time.zone.today + Setting.redemption_grace_period.days + 1.day
    stop_all_pending_actions
    allow_deletion
    save(validate: false)
  end

  def cancel_force_delete
    restore_statuses_before_force_delete
    remove_force_delete_statuses
    self.force_delete_date = nil
    save(validate: false)
  end

  private

  def stop_all_pending_actions
    statuses.delete(DomainStatus::PENDING_UPDATE)
    statuses.delete(DomainStatus::PENDING_TRANSFER)
    statuses.delete(DomainStatus::PENDING_RENEW)
    statuses.delete(DomainStatus::PENDING_CREATE)
  end

  def preserve_current_statuses_for_force_delete
    self.statuses_before_force_delete = statuses.clone
  end

  def restore_statuses_before_force_delete
    self.statuses = statuses_before_force_delete
    self.statuses_before_force_delete = nil
  end

  def add_force_delete_statuses
    statuses << DomainStatus::FORCE_DELETE
    statuses << DomainStatus::SERVER_RENEW_PROHIBITED
    statuses << DomainStatus::SERVER_TRANSFER_PROHIBITED
    statuses << DomainStatus::SERVER_UPDATE_PROHIBITED
    statuses << DomainStatus::PENDING_DELETE

    if (statuses & [DomainStatus::SERVER_HOLD, DomainStatus::CLIENT_HOLD]).empty?
      statuses << DomainStatus::SERVER_MANUAL_INZONE
    end
  end

  def remove_force_delete_statuses
    statuses.delete(DomainStatus::FORCE_DELETE)
    statuses.delete(DomainStatus::SERVER_RENEW_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_TRANSFER_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_UPDATE_PROHIBITED)
    statuses.delete(DomainStatus::PENDING_DELETE)
    statuses.delete(DomainStatus::SERVER_MANUAL_INZONE)
  end

  def allow_deletion
    statuses.delete(DomainStatus::CLIENT_DELETE_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_DELETE_PROHIBITED)
  end
end
