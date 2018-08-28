module Admin
  class DomainsController < BaseController
    before_action :set_domain, only: %i[show edit update keep]
    authorize_resource
    helper_method :force_delete_templates

    def index
      params[:q] ||= {}
      if params[:statuses_contains]
        domains = Domain.includes(:registrar, :registrant).where(
          "domains.statuses @> ?::varchar[]", "{#{params[:statuses_contains].join(',')}}"
        )
      else
        domains = Domain.includes(:registrar, :registrant)
      end

      normalize_search_parameters do
        @q = domains.search(params[:q])
        @domains = @q.result.page(params[:page])
        if @domains.count == 1 && params[:q][:name_matches].present?
          redirect_to [:admin, @domains.first] and return
        elsif @domains.count == 0 && params[:q][:name_matches] !~ /^%.+%$/
          # if we do not get any results, add wildcards to the name field and search again
          n_cache = params[:q][:name_matches]
          params[:q][:name_matches] = "%#{params[:q][:name_matches]}%"
          @q = domains.search(params[:q])
          @domains = @q.result.page(params[:page])
          params[:q][:name_matches] = n_cache # we don't want to show wildcards in search form
        end
      end

      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?
    end

    def show
      # Validation is needed to warn users
      @domain.validate
    end

    def edit
      build_associations
    end

    def update
      dp = ignore_empty_statuses
      @domain.is_admin = true
      @domain.admin_status_update dp[:statuses]

      if @domain.update(dp)
        flash[:notice] = I18n.t('domain_updated')
        redirect_to [:admin, @domain]
      else
        build_associations
        flash.now[:alert] = I18n.t('failed_to_update_domain') + ' ' + @domain.errors.full_messages.join(", ")
        render 'edit'
      end
    end

    def versions
      @domain = Domain.where(id: params[:domain_id]).includes({ versions: :item }).first
      @versions = @domain.versions
    end

    def keep
      @domain.keep
      redirect_to edit_admin_domain_url(@domain), notice: t('.kept')
    end

    private

    def set_domain
      @domain = Domain.find(params[:id])
    end

    def domain_params
      if params[:domain]
        params.require(:domain).permit({ statuses: [], status_notes_array: [] })
      else
        { statuses: [] }
      end
    end

    def build_associations
      @server_statuses = @domain.statuses.select { |x| DomainStatus::SERVER_STATUSES.include?(x) }
      @server_statuses = [nil] if @server_statuses.empty?
      @other_statuses = @domain.statuses.select { |x| !DomainStatus::SERVER_STATUSES.include?(x) }
    end

    def ignore_empty_statuses
      dp = domain_params
      dp[:statuses].reject!(&:blank?)
      dp
    end

    def normalize_search_parameters
      ca_cache = params[:q][:valid_to_lteq]
      begin
        end_time = params[:q][:valid_to_lteq].try(:to_date)
        params[:q][:valid_to_lteq] = end_time.try(:end_of_day)
      rescue
        logger.warn('Invalid date')
      end

      yield

      params[:q][:valid_to_lteq] = ca_cache
    end

    def force_delete_templates
      %w(removed_company death)
    end
  end
end
