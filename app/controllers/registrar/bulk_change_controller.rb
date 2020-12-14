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
      set_form_data

      if domain_ids_for_bulk_renew.present?
        domains = Epp::Domain.where(id: domain_ids_for_bulk_renew).to_a
        task = renew_task(domains)
        flash[:notice] = flash_message(task)
      end
      render file: 'registrar/bulk_change/new', locals: { active_tab: :bulk_renew }
    end

    private

    def set_form_data
      @expire_date = params[:expire_date].to_date
      @domains = domains_by_date(@expire_date)
      @period = params[:period]
    end

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

    def domain_ids_for_bulk_renew
      params.dig('domain_ids')&.reject { |id| id.blank? }
    end

    def renew_task(domains)
      Domains::BulkRenew::Start.run(domains: domains,
                                    period_element: @period,
                                    registrar: current_registrar_user.registrar)
    end

    def flash_message(task)
      if task.valid?
        t(:bulk_renew_completed)
      else
        task.errors.full_messages.join(' and ')
      end
    end
  end
end
