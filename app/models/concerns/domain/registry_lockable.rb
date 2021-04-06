module Domain::RegistryLockable
  extend ActiveSupport::Concern

  LOCK_STATUSES = [DomainStatus::SERVER_UPDATE_PROHIBITED,
                   DomainStatus::SERVER_DELETE_PROHIBITED,
                   DomainStatus::SERVER_TRANSFER_PROHIBITED].freeze

  def apply_registry_lock
    return unless registry_lockable?
    return if locked_by_registrant?

    save_statuses_history

    transaction do
      self.statuses |= LOCK_STATUSES
      self.locked_by_registrant_at = Time.zone.now
      alert_registrar_lock_changes!(lock: true)

      save!
    end
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
      LOCK_STATUSES.each do |domain_status|
        remove_predetermined_statuses domain_status
      end
      self.locked_by_registrant_at = nil
      clear_locked_domain_statuses_history
      alert_registrar_lock_changes!(lock: false)

      save!
    end
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

  private

  def save_statuses_history
    self.locked_domain_statuses_history = statuses.map do |status|
      status if LOCK_STATUSES.include? status
    end
  end

  def remove_predetermined_statuses(domain_status)
    statuses.delete(domain_status) unless locked_domain_statuses_history.include? domain_status
  end

  def clear_locked_domain_statuses_history
    self.locked_domain_statuses_history = nil
  end
end
