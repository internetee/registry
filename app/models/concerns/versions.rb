# Papertrail concerns is mainly tested at country spec
module Versions
  extend ActiveSupport::Concern

  included do
    attr_accessor :version_loader
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
      registrar = Registrar.find_by(name: str)
      user = registrar.api_users.first if registrar

      str_match = str.match(/^(\d+)-(ApiUser:|api-|AdminUser:)/)
      user ||= User.find_by(id: str_match[1]) if str_match

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

  module ClassMethods
    def all_versions_for(ids, time)
      ver_klass    = paper_trail_version_class
      from_history = ver_klass.where(item_id: ids.to_a).
          order(:item_id).
          preceding(time + 1, true).
          select("distinct on (item_id) #{ver_klass.table_name}.*").
          map do |ver|
            o = new(ver.object)
            o.version_loader = ver
            ver.object_changes.to_h.each { |k, v| o.public_send("#{k}=", v[-1]) }
            o
          end
      not_in_history = where(id: (ids.to_a - from_history.map(&:id)))

      from_history + not_in_history
    end
  end
end
