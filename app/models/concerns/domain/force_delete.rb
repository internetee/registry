module Concerns::Domain::ForceDelete
  extend ActiveSupport::Concern

  included do
    alias_attribute :force_delete_time, :force_delete_at
  end

  def force_delete_scheduled?
    statuses.include?(DomainStatus::FORCE_DELETE)
  end

  def schedule_force_delete
    self.statuses_backup = statuses
    statuses.delete(DomainStatus::CLIENT_DELETE_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_DELETE_PROHIBITED)
    statuses.delete(DomainStatus::PENDING_UPDATE)
    statuses.delete(DomainStatus::PENDING_TRANSFER)
    statuses.delete(DomainStatus::PENDING_RENEW)
    statuses.delete(DomainStatus::PENDING_CREATE)

    statuses.delete(DomainStatus::FORCE_DELETE)
    statuses.delete(DomainStatus::SERVER_RENEW_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_TRANSFER_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_UPDATE_PROHIBITED)
    statuses.delete(DomainStatus::SERVER_MANUAL_INZONE)
    statuses.delete(DomainStatus::PENDING_DELETE)

    statuses << DomainStatus::FORCE_DELETE
    statuses << DomainStatus::SERVER_RENEW_PROHIBITED
    statuses << DomainStatus::SERVER_TRANSFER_PROHIBITED
    statuses << DomainStatus::SERVER_UPDATE_PROHIBITED
    statuses << DomainStatus::PENDING_DELETE

    if (statuses & [DomainStatus::SERVER_HOLD, DomainStatus::CLIENT_HOLD]).empty?
      statuses << DomainStatus::SERVER_MANUAL_INZONE
    end

    self.force_delete_at = (Time.zone.now + (Setting.redemption_grace_period.days + 1.day)).utc.beginning_of_day unless force_delete_at
    save!(validate: false)
  end

  def cancel_force_delete
    s = []
    s << DomainStatus::EXPIRED if statuses.include?(DomainStatus::EXPIRED)
    s << DomainStatus::SERVER_HOLD if statuses.include?(DomainStatus::SERVER_HOLD)
    s << DomainStatus::DELETE_CANDIDATE if statuses.include?(DomainStatus::DELETE_CANDIDATE)

    self.statuses = (statuses_backup + s).uniq

    self.force_delete_at = nil
    self.statuses_backup = []
    save(validate: false)
  end
end
