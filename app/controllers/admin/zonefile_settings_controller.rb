class Admin::ZonefileSettingsController < AdminController
  load_and_authorize_resource
  before_action :set_zonefile_setting, only: [:update, :edit]
  def index
    @zonefile_settings = ZonefileSetting.all
  end

  def new
    @zonefile_setting = ZonefileSetting.new
  end

  def create
    @zonefile_setting = ZonefileSetting.new(zonefile_setting_params)

    if @zonefile_setting.save
      flash[:notice] = I18n.t('record_created')
      redirect_to admin_zonefile_settings_path
    else
      flash.now[:alert] = I18n.t('failed_to_create_record')
      render 'new'
    end
  end

  def edit
    @zonefile_setting = ZonefileSetting.find(params[:id])
  end

  def update
    if @zonefile_setting.update(zonefile_setting_params)
      flash[:notice] = I18n.t('record_updated')
      redirect_to admin_zonefile_settings_path
    else
      flash.now[:alert] = I18n.t('failed_to_update_record')
      render 'edit'
    end
  end

  private

  def set_zonefile_setting
    @zonefile_setting = ZonefileSetting.find(params[:id])
  end

  def zonefile_setting_params
    params.require(:zonefile_setting).permit(
      :origin, :ttl, :refresh, :retry, :expire, :minimum_ttl, :email, :ns_records, :a_records, :a4_records
    )
  end
end
