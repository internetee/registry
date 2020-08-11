module Admin
  class SettingsController < BaseController
    load_and_authorize_resource

    def index
      @settings = SettingEntry.unscoped
      @validation_settings = SettingEntry.with_group('domain_validation')
      @expiration_settings = SettingEntry.with_group('domain_expiration')
      @other_settings = SettingEntry.with_group('other')
      @billing_settings = SettingEntry.with_group('billing')
      @contacts_settings = SettingEntry.with_group('contacts')
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

      params[:settings].each do |k, v|
        settings[k] = v
        settings[k] = v.to_i if Setting.integer_settings.include?(k.to_sym)
        settings[k] = v.to_f if Setting.float_settings.include?(k.to_sym)
        settings[k] = (v == 'true' ? true : false) if Setting.boolean_settings.include?(k.to_sym)
      end

      settings
    end
  end
end
