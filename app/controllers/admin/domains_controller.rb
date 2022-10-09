module Admin
  class DomainsController < BaseController
    DEFAULT_VERSIONS_PER_PAGE = 10

    before_action :set_domain, only: %i[show edit update download keep]
    authorize_resource

    # rubocop:disable Metrics/MethodLength
    def index
      params[:q] ||= {}
      domains = if params[:statuses_contains]
                  Domain.includes(:registrar, :registrant).where(
                    "domains.statuses @> ?::varchar[]", "{#{params[:statuses_contains].join(',')}}"
                  )
                else
                  Domain.includes(:registrar, :registrant)
                end

      normalize_search_parameters do
        @q = domains.ransack(PartialSearchFormatter.format(params[:q]))
        @domains = @q.result.page(params[:page])
      end

      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/domains/index', 'domains')
    end
    # rubocop:enable Metrics/MethodLength

    def show
      # Validation is needed to warn users
      @domain.validate
    end

    def edit
      build_associations
    end

    # rubocop:disable Metrics/MethodLength
    def update
      rollback_history = @domain.json_statuses_history&.[]('admin_store_statuses_history')
      dp = ignore_empty_statuses
      @domain.is_admin = true
      @domain.admin_status_update dp[:statuses]

      if @domain.update(dp)
        flash[:notice] = I18n.t('domain_updated')
        redirect_to [:admin, @domain]
      else
        @domain.reload
        @domain.admin_status_update rollback_history
        build_associations
        flash.now[:alert] = "#{I18n.t('failed_to_update_domain')} #{@domain.errors.full_messages.join(', ')}"
        render 'edit'
      end
    end
    # rubocop:enable Metrics/MethodLength

    def versions
      @domain = Domain.where(id: params[:domain_id]).includes({ versions: :item }).first
      @versions = @domain.versions
      @last_version = @versions.last
      @old_versions = Kaminari.paginate_array(@versions.not_creates.reverse)
                              .page(params[:page])
                              .per(DEFAULT_VERSIONS_PER_PAGE)
    end

    def download
      filename = "#{@domain.name}.pdf"
      send_data @domain.as_pdf, filename: filename
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
      @other_statuses = @domain.statuses.reject { |x| DomainStatus::SERVER_STATUSES.include?(x) }
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
  end
end
