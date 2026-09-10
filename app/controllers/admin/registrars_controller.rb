require 'net/http'
require 'securerandom'
require 'stringio'

module Admin
  class RegistrarsController < BaseController # rubocop:disable Metrics/ClassLength
    load_and_authorize_resource
    before_action :set_registrar, only: %i[show edit update destroy]
    before_action :set_registrar_status_filter, only: [:index]
    helper_method :registry_vat_rate
    helper_method :iban_max_length

    SQL_SUM_STR = 'sum(case active when TRUE then 1 else 0 end)'.freeze

    def index
      registrars = filter_by_status
      @q = registrars.ransack(params[:q])
      @registrars_scope = @q.result(distinct: true)
      @registrars = @registrars_scope.page(params[:page])
      @registrars = @registrars.per(params[:results_per_page]) if paginate?

      respond_to do |format|
        format.html
        format.csv do
          export_scope = selected_export_scope(@registrars_scope)
          send_data(
            CsvSync::Exporter.call(
              model_class: Registrar,
              records: export_scope,
              fields: csv_export_fields
            ),
            filename: "registrars-#{Time.zone.today}.csv",
            type: 'text/csv'
          )
        end
      end
    end

    def new
      @registrar = Registrar.new
    end

    def create
      @registrar = Registrar.new(registrar_params)
      @registrar.reference_no = ::Billing::ReferenceNo.generate(owner: @registrar.name)

      if @registrar.valid?
        @registrar.transaction do
          @registrar.save!
          @registrar.accounts.create!(account_type: Account::CASH, currency: 'EUR')
        end

        redirect_to [:admin, @registrar], notice: t('.created')
      else
        render :new
      end
    end

    def edit; end

    def show
      method = allowed_method(params[:records]) || 'api_users'
      @result = @registrar.send(method.to_sym)
      partial_name = "#{@registrar.name.parameterize}_#{method}"
      render_by_format('admin/registrars/show', partial_name)
    end

    def update
      if @registrar.update(registrar_params)
        redirect_to [:admin, @registrar], notice: t('.updated')
      else
        render :edit
      end
    end

    def destroy
      if @registrar.destroy
        flash[:notice] = t('.deleted')
        redirect_to admin_registrars_url
      else
        flash[:alert] = @registrar.errors.full_messages.first
        redirect_to admin_registrar_url(@registrar)
      end
    end

    def import
      @csv_sync_fields = Registrar.csv_sync_default_import_fields
      @selected_fields = @csv_sync_fields
      @csv_sync_field_groups = csv_sync_field_groups
    end

    def import_preview
      set_import_form_defaults
      @result = empty_import_result

      if params[:file].blank?
        flash.now[:alert] = t('admin.registrars.import_preview.file_required')
        return render :import
      end

      @result = CsvSync::Importer.preview(
        model_class: Registrar,
        file: params[:file],
        fields: @selected_fields
      )
      @row_results = @result.row_results
      @import_token = cache_import_file(params[:file])
      render :import_preview
    rescue StandardError => e
      @result = empty_import_result(errors: 1, row_results: [{ line_number: '-', action: :error, key_values: {}, changes: [], error: e.message }])
      flash.now[:alert] = t('admin.registrars.import_preview.failed')
      render :import
    end

    def import_apply
      set_import_form_defaults
      @result = empty_import_result
      file = file_from_apply_params

      if file.blank?
        flash[:alert] = t('admin.registrars.import_apply.file_not_found')
        return redirect_to import_admin_registrars_path
      end

      @result = CsvSync::Importer.apply(
        model_class: Registrar,
        file: file,
        fields: @selected_fields
      )
      clear_cached_import_file(params[:import_token])

      flash[:notice] = t(
        'admin.registrars.import_apply.completed',
        created: @result.created,
        updated: @result.updated,
        unchanged: @result.unchanged,
        errors: @result.errors
      )
      redirect_to admin_registrars_path
    rescue StandardError => e
      flash[:alert] = "#{t('admin.registrars.import_apply.failed')}: #{e.message}"
      redirect_to import_admin_registrars_path
    end

    private

    def filter_by_status
      case params[:status]
      when 'Active'
        active_registrars
      when 'Inactive'
        inactive_registrars
      else
        Registrar.includes(:accounts, :api_users).ordered
      end
    end

    def active_registrars
      Registrar.includes(:accounts, :api_users).where(
        id: ApiUser.having("#{SQL_SUM_STR} > 0").group(:registrar_id).pluck(:registrar_id)
      ).ordered
    end

    def inactive_registrars
      Registrar.includes(:accounts, :api_users).where(api_users: { id: nil }).or(
        Registrar.includes(:accounts, :api_users).where(
          id: ApiUser.having("#{SQL_SUM_STR} = 0").group(:registrar_id).pluck(:registrar_id)
        )
      ).ordered
    end

    def set_registrar_status_filter
      params[:status] ||= 'Active'
    end

    def set_registrar
      @registrar = Registrar.find(params[:id])
    end

    def registrar_params
      params.require(:registrar).permit(:name,
                                        :reg_no,
                                        :email,
                                        :address_street,
                                        :address_zip,
                                        :address_city,
                                        :address_state,
                                        :address_country_code,
                                        :phone,
                                        :website,
                                        :code,
                                        :test_registrar,
                                        :vat_no,
                                        :vat_rate,
                                        :accounting_customer_code,
                                        :billing_email,
                                        :legaldoc_optout,
                                        :legaldoc_optout_comment,
                                        :iban,
                                        :language)
    end

    def registry_vat_rate
      Registry.current.vat_rate
    end

    def iban_max_length
      Iban.max_length
    end

    def allowed_method(records_param)
      allowed_methods = %w[api_users white_ips]
      records_param if allowed_methods.include?(records_param)
    end

    def csv_export_fields
      params.fetch(:csv_fields, []).reject(&:blank?)
    end

    def selected_export_scope(scope)
      return scope unless params[:export_selected].present?

      selected_ids = params.fetch(:registrar_ids, []).reject(&:blank?)
      return scope.none if selected_ids.empty?

      scope.where(id: selected_ids)
    end

    def set_import_form_defaults
      @csv_sync_fields = Registrar.csv_sync_default_import_fields
      @selected_fields = params.fetch(:fields, []).reject(&:blank?)
      @selected_fields = @csv_sync_fields if @selected_fields.empty?
      @csv_sync_field_groups = csv_sync_field_groups
    end

    def csv_sync_field_groups
      { t('admin.csv_sync.field_checkboxes.default_group') => Registrar.csv_sync_default_import_fields }
    end

    def empty_import_result(errors: 0, row_results: [])
      CsvSync::Importer::Result.new(
        created: 0,
        updated: 0,
        unchanged: 0,
        errors: errors,
        row_results: row_results
      )
    end

    def cache_import_file(file)
      token = SecureRandom.uuid
      io = file.respond_to?(:tempfile) ? file.tempfile : file
      io.rewind if io.respond_to?(:rewind)
      csv_payload = io.read
      session[:registrars_csv_imports] ||= {}
      session[:registrars_csv_imports][token] = csv_payload
      token
    end

    def file_from_apply_params
      return params[:file] if params[:file].present?
      return nil if params[:import_token].blank?

      csv_payload = session.fetch(:registrars_csv_imports, {})[params[:import_token]]
      return nil if csv_payload.blank?

      StringIO.new(csv_payload)
    end

    def clear_cached_import_file(token)
      return if token.blank?

      session[:registrars_csv_imports]&.delete(token)
    end
  end
end
