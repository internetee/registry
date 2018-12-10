module Concerns
  module Contact
    module Disclosable
      extend ActiveSupport::Concern

      class_methods do
        attr_accessor :disclosable_attributes
      end

      included do
        self.disclosable_attributes = %w[name email]
        validate :validate_disclosed_attributes
      end

      private

      def validate_disclosed_attributes
        return if disclosed_attributes.empty?

        has_undisclosable_attributes = (disclosed_attributes - self.class.disclosable_attributes)
                                       .any?
        errors.add(:disclosed_attributes, :invalid) if has_undisclosable_attributes
      end
    end
  end
end
