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

      if ready_to_renew?
        res = Depp::Domain.bulk_renew(domain_ids_for_bulk_renew, params[:period],
                                      current_registrar_user.registrar)

        flash_message(JSON.parse(res))
      else
        flash[:notice] = nil
      end

      render file: 'registrar/bulk_change/new', locals: { active_tab: :bulk_renew }
    end

    private

    def ready_to_renew?
      domain_ids_for_bulk_renew.present? && params[:renew].present?
    end

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

    def flash_message(res)
      flash[:notice] = res['code'] == 1000 ? t(:bulk_renew_completed) : res['message']
    end
  end
end
