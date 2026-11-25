module Admin
  class ReservedDomainLifecyclesController < BaseController
    # Runs before the resource is loaded so show finds lifecycles created
    # since the previous catch-up.
    before_action :sync_lifecycles, only: %i[index show]
    load_and_authorize_resource class: 'ReservedDomain::Lifecycle'

    def index
      params[:q] ||= {}
      normalize_domain_name_param

      search_params = PartialSearchFormatter.format(fix_date_params)
      lifecycles = ReservedDomain::Lifecycle.order(last_changed_at: :desc, id: :desc)
      @q = lifecycles.ransack(search_params)
      @result = @q.result
      @lifecycles = @result.page(params[:page])
      @lifecycles = @lifecycles.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      respond_to do |format|
        format.html { render 'admin/reserved_domain_lifecycles/index' }
        format.csv { stream_csv }
      end
    end

    def show
      @lifecycle = @reserved_domain_lifecycle
      @versions = @lifecycle.versions.to_a
      @registrars = Registrar.where(id: @versions.map(&:registrar_id).compact).index_by(&:id)
      @domain_exists = ReservedDomain::Lifecycle.registered_names([@lifecycle.domain_name])
                                                .include?(@lifecycle.domain_name)
    end

    private

    # A failed catch-up must never break the page: serve what the table has.
    def sync_lifecycles
      ReservedDomain::Lifecycle.sync!
    rescue StandardError => e
      Rails.logger.error("Reserved domain lifecycle sync failed: #{e.class}: #{e.message}")
      flash.now[:warning] = t('admin.reserved_domain_lifecycles.sync_failed')
    end

    # Last-Modified keeps Rack::ETag from buffering the body.
    def stream_csv
      filename = "reserved_domains_history_#{Time.zone.now.to_formatted_s(:number)}.csv"
      response.headers['Content-Type'] = "#{Mime[:csv]}; charset=utf-8"
      response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      response.headers['Cache-Control'] = 'no-cache'
      response.headers['Last-Modified'] = Time.now.httpdate
      response.headers['X-Accel-Buffering'] = 'no'
      self.response_body = ReservedDomain::Lifecycle.csv_lines(@result)
    end

    # Domain names are stored in unicode; accept punycode input too.
    def normalize_domain_name_param
      return if params[:q][:domain_name_matches].blank?

      params[:q][:domain_name_matches] = SimpleIDN.to_unicode(params[:q][:domain_name_matches])
    end

    def fix_date_params
      params_copy = params[:q].deep_dup
      %w[created_at_lteq last_changed_at_lteq].each do |key|
        next if params_copy[key].blank?

        params_copy[key] = Date.parse(params_copy[key]) + 1.day
      rescue ArgumentError
        params_copy.delete(key)
      end

      params_copy
    end
  end
end
