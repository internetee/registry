class Admin::ZonefileSettingsController < ApplicationController
  load_and_authorize_resource
  before_action :set_zonefile_setting, only: [:update, :edit]
  def index
    @zonefile_settings = ZonefileSetting.all
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
    params.require(:zonefile_setting).permit(:ttl, :refresh, :retry, :expire, :minimum_ttl, :email)
  end
end
