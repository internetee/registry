# Papertrail concerns is mainly tested at country spec
module Versions
  extend ActiveSupport::Concern

  included do
    has_paper_trail class_name: "#{model_name}Version"

    # add creator and updator
    before_create :add_creator
    before_create :add_updator
    before_update :add_updator

    def add_creator
      self.creator_str = ::PaperTrail.whodunnit
      true
    end

    def add_updator
      self.updator_str = ::PaperTrail.whodunnit
      true
    end

    def creator
      return nil if creator_str.blank?
      creator = user_from_id_role_username creator_str
      creator.present? ? creator : creator_str
    end

    def updator
      return nil if updator_str.blank?
      updator = user_from_id_role_username updator_str
      updator.present? ? updator : updator_str
    end

    def user_from_id_role_username(str)
      user = ApiUser.find_by(id: $1) if str =~ /^(\d+)-(ApiUser:|api-)/
      unless user.present?
        user = AdminUser.find_by(id: $1) if str =~ /^(\d+)-AdminUser:/
        unless user.present?
          # on import we copied Registrar name, which may eql code
          registrar = Registrar.find_by(name: str)
          # assume each registrar has only one user
          user = registrar.api_users.first if registrar
        end
      end
      user
    end

    # callbacks
    def touch_domain_version
      domain.try(:touch_with_version)
    end

    def touch_domains_version
      domains.each(&:touch_with_version)
    end
  end
end
