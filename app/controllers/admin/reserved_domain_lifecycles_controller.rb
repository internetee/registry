module Admin
  class ReservedDomainLifecyclesController < BaseController
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
        format.csv do
          send_data ReservedDomain::Lifecycle.to_csv(@result),
                    filename: "reserved_domains_history_#{Time.zone.now.to_formatted_s(:number)}.csv",
                    type: "#{Mime[:csv]}; charset=utf-8"
        end
      end
    end

    def show
      @lifecycle = @reserved_domain_lifecycle
      @versions = @lifecycle.versions.to_a
      @registrars = Registrar.where(id: @versions.map(&:registrar_id).compact).index_by(&:id)
    end

    private

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
