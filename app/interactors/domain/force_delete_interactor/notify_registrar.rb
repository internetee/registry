class Domain
  module ForceDeleteInteractor
    class NotifyRegistrar < Base
      def call
        domain.registrar.notifications.create!(text: I18n.t('force_delete_set_on_domain',
                                                            domain_name: domain.name,
                                                            outzone_date: domain.outzone_date,
                                                            purge_date: domain.purge_date))
      end
    end
  end
end
