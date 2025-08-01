module Admin
  class DomainsController < BaseController
    DEFAULT_VERSIONS_PER_PAGE = 10

    before_action :set_domain, only: %i[show edit update download keep]
    authorize_resource

    # rubocop:disable Metrics/MethodLength
    def index
      params[:q] ||= {}
      domains = Domain.includes(:registrar, :registrant).joins(:registrar, :registrant)
      p = params[:statuses_contains]
      domains = domains.where('domains.statuses @> ?::varchar[]', "{#{p.join(',')}}") if p.present?

      normalize_search_parameters do
        @q = domains.ransack(PartialSearchFormatter.format(params[:q]))
        @result = @q.result.distinct
        @domains = @result.page(params[:page])
      end

      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/domains/index', 'domains')
    end

    def update
      rollback_history = @domain.json_statuses_history&.[]('admin_store_statuses_history')
      dp = ignore_empty_statuses
      @domain.is_admin = true
      @domain.admin_status_update dp[:statuses]

      if @domain.update(dp)
        flash[:notice] = I18n.t('domain_updated')
        inform_registrar_about_status_changes
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

    def show
      # Validation is needed to warn users
      @domain.validate
    end

    def edit
      build_associations
    end

    def versions
      @domain = get_domain_with_versions
      @versions = @domain.versions
      @old_versions = paginate_versions(@versions.not_creates.reverse)

      post_update_domains = generate_collection_of_post_update_domains(@old_versions.to_a)
      @post_update_domains = sort_post_update_domains(post_update_domains)
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

    def get_domain_with_versions
      Domain.where(id: params[:domain_id]).includes({ versions: :item }).first
    end

    def paginate_versions(versions)
      Kaminari.paginate_array(versions).page(params[:page]).per(DEFAULT_VERSIONS_PER_PAGE)
    end

    def generate_collection_of_post_update_domains(old_versions_arr)
      post_update_domains = []

      old_versions_arr.each_with_index do |version, idx|
        next_version = old_versions_arr[idx - 1] # reverse order!
        if next_version
          post_update_domains << (next_version.reify || @domain)
        else
          post_update_domains << @domain
        end
      end

      post_update_domains
    end

    def sort_post_update_domains(post_update_domains)
      post_update_domains.sort_by! { |d| -d.updated_at.to_i }
    end

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

    def inform_registrar_about_status_changes
      return unless @domain.saved_change_to_statuses?

      old_statuses, new_statuses = @domain.saved_change_to_statuses
      removed = old_statuses - new_statuses
      added   = new_statuses - old_statuses
  
      added.each do |status|
        @domain.registrar.notifications.create!(text: "#{status} set on domain #{@domain.name}")
      end

      removed.each do |status|
        @domain.registrar.notifications.create!(text: "#{status} is cancelled on domain #{@domain.name}")
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
