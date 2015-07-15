class Admin::SettingsController < AdminController
  load_and_authorize_resource
  before_action :set_setting_group, only: [:show, :update]

  def index
    @settings = Setting.unscoped
  end

  def create
    casted_settings.each do |k, v|
      Setting[k] = v
    end

    flash[:notice] = I18n.t('records_updated')
    redirect_to [:admin, :settings]
  end

  def show; end

  def update
    if @setting_group.update(setting_group_params)
      flash[:notice] = I18n.t('setting_updated')
      redirect_to [:admin, @setting_group]
    else
      flash[:alert] = I18n.t('failed_to_update_setting')
      render 'show'
    end
  end

  private

  def set_setting_group
    @setting_group = SettingGroup.find(params[:id])
  end

  def setting_group_params
    params.require(:setting_group).permit(settings_attributes: [:value, :id])
  end

  def casted_settings # rubocop:disable Metrics/MethodLength
    settings = {}

    ints = [
      :admin_contacts_min_count,
      :admin_contacts_max_count,
      :tech_contacts_min_count,
      :tech_contacts_max_count,
      :ds_algorithm,
      :dnskeys_min_count,
      :dnskeys_max_count,
      :ns_min_count,
      :ns_max_count,
      :transfer_wait_time,
      :invoice_number_min,
      :invoice_number_max,
      :days_to_keep_overdue_invoices_active,
      :days_to_renew_domain_before_expire,
      :expire_warning_period,
      :redemption_grace_period,
      :expire_pending_confirmation
    ]

    floats = [:registry_vat_prc]

    booleans = [
      :ds_data_allowed,
      :key_data_allowed,
      :client_side_status_editing_enabled,
      :registrar_ip_whitelist_enabled,
      :api_ip_whitelist_enabled
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
