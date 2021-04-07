module Domain::RegistryLockable
  extend ActiveSupport::Concern

  class SetRegistratLock < Base
    LOCK_STATUSES = [DomainStatus::SERVER_UPDATE_PROHIBITED,
                      DomainStatus::SERVER_DELETE_PROHIBITED,
                      DomainStatus::SERVER_TRANSFER_PROHIBITED].freeze

    def execute
      transaction do
        self.statuses |= LOCK_STATUSES
        self.locked_by_registrant_at = Time.zone.now
        alert_registrar_lock_changes!(lock: true)

        save!
        end
    end

    private

    def alert_registrar_lock_changes!(lock: true)
      translation = lock ? 'locked' : 'unlocked'
      registrar.notifications.create!(
        text: I18n.t("notifications.texts.registrar_#{translation}",
                    domain_name: name),
        attached_obj_id: name,
        attached_obj_type: self.class.name
      )
    end
  end
end