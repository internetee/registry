class Domain
  module ForceDelete
    class NotifyRegistrar
      include Interactor

      def call
        domain = context.domain

        domain.registrar.notifications.create!(text: t('force_delete_set_on_domain',
                                                       domain_name: domain.name,
                                                       outzone_date: domain.outzone_date,
                                                       purge_date: domain.purge_date))
      end
    end
  end
end
