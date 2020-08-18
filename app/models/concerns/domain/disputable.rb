# frozen_string_literal: true

module Concerns
  module Domain
    module Disputable
      extend ActiveSupport::Concern

      included do
        validate :validate_disputed
      end

      def mark_as_disputed
        statuses.push(DomainStatus::DISPUTED) unless statuses.include?(DomainStatus::DISPUTED)
        save
      end

      def unmark_as_disputed
        statuses.delete_if { |status| status == DomainStatus::DISPUTED }
        save
      end

      def in_disputed_list?
        @in_disputed_list ||= Dispute.active.find_by(domain_name: name).present?
      end

      def disputed?
        Dispute.active.where(domain_name: name).any?
      end

      def validate_disputed
        return if persisted? || !in_disputed_list?

        if reserved_pw.blank?
          errors.add(:base, :required_parameter_missing_disputed)
          return false
        end

        return if Dispute.valid_auth?(name, reserved_pw)

        errors.add(:base, :invalid_auth_information_reserved)
      end
    end
  end
end
