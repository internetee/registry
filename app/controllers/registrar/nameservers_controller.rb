class Registrar::NameserversController < RegistrarController
  # turned off requested by client

  # load_and_authorize_resource

  # def index
    # if can_replace_hostnames?
      # prc = Nameserver.replace_hostname_ends(
        # current_user.registrar.domains.includes(
          # :registrant, :nameservers, :admin_domain_contacts, :tech_domain_contacts, :domain_statuses,
          # :versions, :admin_contacts, :tech_contacts, :whois_record, :dnskeys
        # ),
        # params[:q][:hostname_end],
        # params[:hostname_end_replacement]
      # )

      # if prc == 'replaced_none'
        # flash.now[:alert] = t(:no_hostnames_replaced)
      # elsif prc == 'replaced_all'
        # params[:q][:hostname_end] = params[:hostname_end_replacement]
        # params[:hostname_end_replacement] = nil
        # flash.now[:notice] = t(:all_hostnames_replaced)
      # else
        # flash.now[:warning] = t(:hostnames_partially_replaced)
      # end
    # end

    # nameservers = current_user.registrar.nameservers.includes(:domain)
    # @q = nameservers.search(params[:q])
    # @q.sorts  = 'id desc' if @q.sorts.empty?
    # @nameservers = @q.result.page(params[:page])
  # end

  # def replace_all
    # @domain_params = { nameservers_attributes: { 0 => {} } }
  # end

  # private

  # def can_replace_hostnames?
    # if params[:replace] && params[:q]
      # flash.now[:alert] = t('hostname_end_replacement_is_required') unless params[:hostname_end_replacement].present?
      # flash.now[:alert] = t('hostname_end_is_required') unless params[:q][:hostname_end].present?
      # return true if flash[:alert].blank?
    # end
    # false
  # end
end
