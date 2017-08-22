module Admin
  class SettingsController < BaseController
    load_and_authorize_resource

    def index
      @settings = Setting.unscoped
    end

    def create
      @errors = Setting.params_errors(casted_settings)
      if @errors.empty?
        casted_settings.each do |k, v|
          Setting[k] = v
        end

        flash[:notice] = t('.saved')
        redirect_to [:admin, :settings]
      else
        flash[:alert] = @errors.values.uniq.join(", ")
        render "admin/settings/index"
      end
    end

    private

    def casted_settings
      settings = {}

      ints = [
        :admin_contacts_min_count,
        :admin_contacts_max_count,
        :tech_contacts_min_count,
        :tech_contacts_max_count,
        :orphans_contacts_in_months,
        :ds_digest_type,
        :dnskeys_min_count,
        :dnskeys_max_count,
        :ns_min_count,
        :ns_max_count,
        :transfer_wait_time,
        :invoice_number_min,
        :invoice_number_max,
        :days_to_keep_business_registry_cache,
        :days_to_keep_invoices_active,
        :days_to_keep_overdue_invoices_active,
        :days_to_renew_domain_before_expire,
        :expire_warning_period,
        :redemption_grace_period,
        :expire_pending_confirmation
      ]

      floats = [:registry_vat_prc, :minimum_deposit]

      booleans = [
        :ds_data_allowed,
        :key_data_allowed,
        :client_side_status_editing_enabled,
        :registrar_ip_whitelist_enabled,
        :api_ip_whitelist_enabled,
        :request_confrimation_on_registrant_change_enabled,
        :request_confirmation_on_domain_deletion_enabled,
        :nameserver_required,
        :address_processing
      ]

      params[:settings].each do |k, v|
        settings[k] = v
        settings[k] = v.to_i if ints.include?(k.to_sym)
        settings[k] = v.to_f if floats.include?(k.to_sym)
        settings[k] = (v == 'true' ? true : false) if booleans.include?(k.to_sym)
      end

      settings
    end
  end
end
