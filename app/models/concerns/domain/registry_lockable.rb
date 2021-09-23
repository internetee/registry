module Domain::RegistryLockable
  extend ActiveSupport::Concern

  LOCK_STATUSES = if Feature.obj_and_extensions_statuses_enabled?
                    [DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED,
                     DomainStatus::SERVER_DELETE_PROHIBITED,
                     DomainStatus::SERVER_TRANSFER_PROHIBITED].freeze
                  else
                    [DomainStatus::SERVER_UPDATE_PROHIBITED,
                     DomainStatus::SERVER_DELETE_PROHIBITED,
                     DomainStatus::SERVER_TRANSFER_PROHIBITED].freeze
                  end

  EXTENSIONS_STATUS = [DomainStatus::SERVER_EXTENSION_UPDATE_PROHIBITED].freeze

  def apply_registry_lock(extensions_prohibited:)
    return unless registry_lockable?
    return if locked_by_registrant?

    transaction do
      apply_statuses_locked_statuses(extensions_prohibited: extensions_prohibited)
    end
  end

  def apply_statuses_locked_statuses(extensions_prohibited:)
    self.statuses |= LOCK_STATUSES
    self.statuses |= EXTENSIONS_STATUS if Feature.obj_and_extensions_statuses_enabled? && extensions_prohibited
    self.locked_by_registrant_at = Time.zone.now
    alert_registrar_lock_changes!(lock: true)

    save!
  end

  def registry_lockable?
    (statuses & [DomainStatus::PENDING_DELETE_CONFIRMATION,
                 DomainStatus::PENDING_CREATE, DomainStatus::PENDING_UPDATE,
                 DomainStatus::PENDING_DELETE, DomainStatus::PENDING_RENEW,
                 DomainStatus::PENDING_TRANSFER, DomainStatus::FORCE_DELETE]).empty?
  end

  def locked_by_registrant?
    return false unless locked_by_registrant_at

    (statuses & LOCK_STATUSES).count == 3
  end

  def remove_registry_lock
    return unless locked_by_registrant?

    transaction do
      remove_statuses_from_locked_domain
    end
  end

  def remove_statuses_from_locked_domain
    LOCK_STATUSES.each do |domain_status|
      statuses.delete([domain_status])
    end

    statuses.delete([EXTENSIONS_STATUS]) if statuses.include? EXTENSIONS_STATUS
    self.locked_by_registrant_at = nil
    self.statuses = admin_store_statuses_history || []
    alert_registrar_lock_changes!(lock: false)

    save!
  end

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
