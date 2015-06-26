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

  def casted_settings
    settings = {}
    params[:settings].each do |k, v|
      settings[k] = v.to_i if Setting[k].class == Fixnum
      settings[k] = v.to_f if Setting[k].class == Float
      settings[k] = (v == 'true' ? true : false) if [TrueClass, FalseClass].include?(Setting[k].class)
      settings[k] = v if Setting[k].class == String
    end
    settings
  end
end
