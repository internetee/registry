class Registrar
  class BulkChangeController < DeppController
    helper_method :available_contacts

    def new
      authorize! :manage, :repp
      @expire_date = Time.zone.now.to_date
      render file: 'registrar/bulk_change/new', locals: { active_tab: default_tab }
    end

    def bulk_renew
      authorize! :manage, :repp
      @expire_date = params[:expire_date].to_date
      # binding.pry
      @domains = domains_by_date(@expire_date)
      render file: 'registrar/bulk_change/new', locals: { active_tab: :bulk_renew }
    end

    private

    def available_contacts
      current_registrar_user.registrar.contacts.order(:name).pluck(:name, :code)
    end

    def default_tab
      :technical_contact
    end

    def domains_scope
      current_registrar_user.registrar.domains
    end

    def domains_by_date(date)
      domains_scope.where('valid_to <= ?', date)
    end
  end
end
