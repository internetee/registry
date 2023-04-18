module Admin
  class ContactVersionsController < BaseController
    include ApplicationHelper

    load_and_authorize_resource class: Version::ContactVersion

    def index
      params[:q] ||= {}

      search_params = PartialSearchFormatter.format(fix_date_params)
      versions = Version::ContactVersion.includes(:item).order(created_at: :desc, id: :desc)
      @q = versions.ransack(polymorphic_association(search_params))
      @result = @q.result
      @versions = @result.page(params[:page])
      @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/contact_versions/index', 'contact_history')
    end

    def show
      per_page = 7
      @version = Version::ContactVersion.find(params[:id])
      @versions = Version::ContactVersion.where(item_id: @version.item_id).order(created_at: :desc, id: :desc)
      @versions_map = @versions.all.map(&:id)

      # what we do is calc amount of results until needed version
      # then we calc which page it is
      if params[:page].blank?
        counter = @versions_map.index(@version.id) + 1
        page = counter / per_page
        page += 1 if (counter % per_page) != 0
        params[:page] = page
      end

      @versions = @versions.page(params[:page]).per(per_page)
    end

    def search
      render json: Version::ContactVersion.search_by_query(params[:q])
    end

    private

    def polymorphic_association(search_params)
      record_type = {}
      fields = %w[name code ident]
      fields.each { |field| record_type[:"item_of_Contact_type_#{field}_matches"] = search_params[:"#{field}_matches"] }

      record_type
    end

    def fix_date_params
      params_copy = params[:q].deep_dup
      if params_copy['created_at_lteq'].present?
        params_copy['created_at_lteq'] = Date.parse(params_copy['created_at_lteq']) + 1.day
      end

      params_copy
    end
  end
end
