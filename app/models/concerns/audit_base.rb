module AuditBase
  extend ActiveSupport::Concern

  included do
    before_create :add_creator
    before_create :add_updator
    before_update :add_updator

    def add_creator
      self.creator_str = ::User.whodunnit || 'console-root'
      true
    end

    def add_updator
      self.updator_str = ::User.whodunnit || 'console-root'
      true
    end

    def creator
      return if creator_str.blank?

      creator = user_from_id_role_username creator_str
      creator.presence || creator_str
    end

    def updator
      return if updator_str.blank?

      updator = user_from_id_role_username updator_str
      updator.presence || updator_str
    end
  end
end
