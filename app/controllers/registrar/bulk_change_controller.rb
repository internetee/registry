class Registrar
  class BulkChangeController < DeppController
    helper_method :available_contacts

    def new
      authorize! :manage, :repp
      render file: 'registrar/bulk_change/new', locals: { active_tab: default_tab }
    end

    private

    def available_contacts
      current_registrar_user.registrar.contacts.order(:name).pluck(:name, :code)
    end

    def default_tab
      :technical_contact
    end
  end
end
