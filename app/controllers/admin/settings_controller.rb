module Admin
  class SettingsController < BaseController
    load_and_authorize_resource

    def index
      @settings = SettingEntry.unscoped
      @validation_settings = SettingEntry.with_group('domain_validation')
      @expiration_settings = SettingEntry.with_group('domain_expiration')
      @other_settings = SettingEntry.with_group('other')
                                    .where.not(code: 'default_language')
      @billing_settings = SettingEntry.with_group('billing')
      @contacts_settings = SettingEntry.with_group('contacts')
    end

    def create
      update = SettingEntry.update(casted_settings.keys, casted_settings.values)
      if update
        flash[:notice] = t('.saved')
        redirect_to %i[admin settings]
      else
        flash[:alert] = update.errors.values.uniq.join(', ')
        render 'admin/settings/index'
      end
    end

    private

    def casted_settings
      settings = {}

      params[:settings].each do |k, v|
        settings[k] = { value: v }
      end

      settings
    end
  end
end
