module Domains
  module Delete
    class NotifyRegistrar < Base
      def execute
        bye_bye = domain.versions.last
        domain.registrar.notifications.create!(
          text: "#{I18n.t(:domain_deleted)}: #{domain.name}",
          attached_obj_id: bye_bye.id,
          attached_obj_type: bye_bye.class.to_s
        )
      end
    end
  end
end
