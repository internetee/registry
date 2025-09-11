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
      @certificate_settings = SettingEntry.with_group('certificate')
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
        setting = SettingEntry.find(k)
        value = if setting.format == 'array'
          processed_hash = available_options.each_with_object({}) do |option, hash|
            hash[option] = (v[option] == "true")
          end
          processed_hash.to_json
        else
          v
        end
        settings[k] = { value: value }
      end
    
      settings
    end
    
    def available_options
      %w[birthday priv org]
    end
  end
end
