module Domains
  module CancelForceDelete
    class NotifyRegistrar < Base
      def execute
        domain.registrar.notifications.create!(text: I18n.t('force_delete_cancelled',
                                                            domain_name: domain.name))
      end
    end
  end
end
