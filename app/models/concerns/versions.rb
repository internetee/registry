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

      if creator_str =~ /^\d+-AdminUser:/
        creator = AdminUser.find_by(id: creator_str)
      elsif creator_str =~ /^\d+-ApiUser:/
        creator = ApiUser.find_by(id: creator_str)
      elsif creator_str =~ /^\d+-api-/ # depricated
        creator = ApiUser.find_by(id: creator_str)
      end

      creator.present? ? creator : creator_str
    end

    def updator
      return nil if updator_str.blank?

      if updator_str =~ /^\d+-AdminUser:/
        updator = AdminUser.find_by(id: updator_str)
      elsif updator_str =~ /^\d+-ApiUser:/
        updator = ApiUser.find_by(id: updator_str)
      elsif updator_str =~ /^\d+-api-/ # depricated
        updator = ApiUser.find_by(id: updator_str)
      end

      updator.present? ? updator : updator_str
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
