module Concerns
  module Domain
    module RegistryLockable
      extend ActiveSupport::Concern

      def apply_registry_lock
        return unless registry_lockable?
        return if locked_by_registrant?

        transaction do
          statuses << DomainStatus::SERVER_UPDATE_PROHIBITED
          statuses << DomainStatus::SERVER_DELETE_PROHIBITED
          statuses << DomainStatus::SERVER_TRANSFER_PROHIBITED
          self.locked_by_registrant_at = Time.zone.now

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

        lock_statuses = [
          DomainStatus::SERVER_UPDATE_PROHIBITED,
          DomainStatus::SERVER_DELETE_PROHIBITED,
          DomainStatus::SERVER_TRANSFER_PROHIBITED,
        ]

        (statuses & lock_statuses).count == 3
      end

      def remove_registry_lock
        return unless locked_by_registrant?

        transaction do
          statuses.delete(DomainStatus::SERVER_UPDATE_PROHIBITED)
          statuses.delete(DomainStatus::SERVER_DELETE_PROHIBITED)
          statuses.delete(DomainStatus::SERVER_TRANSFER_PROHIBITED)
          self.locked_by_registrant_at = nil

          save!
        end
      end
    end
  end
end
