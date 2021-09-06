module Admin
  class ContactVersionsController < BaseController
    include ObjectVersionsHelper

    load_and_authorize_resource class: Version::ContactVersion

    def index
      params[:q] ||= {}

      @q = Version::ContactVersion.ransack(params[:q])
      @versions = @q.result.page(params[:page])
      search_params = params[:q].deep_dup

      whereS = "1=1"

      search_params.each do |key, value|
        next if value.empty?
        case key
          when 'event'
            whereS += " AND event = '#{value}'"
          else
            whereS += create_where_string(key, value)
        end
      end

      versions = Version::ContactVersion.includes(:item).where(whereS).order(created_at: :desc, id: :desc)
      @q = versions.ransack(params[:q])
      @versions = @q.result.page(params[:page])
      @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/contact_versions/index', 'contact_history')
    end

    def show
      per_page = 7
      @version = Version::ContactVersion.find(params[:id])
      @versions = Version::ContactVersion.where(item_id: @version.item_id).order(created_at: :desc, id: :desc)
      @versions_map = @versions.all.map(&:id)

      # what we do is calc amount of results until needed version
      # then we cacl which page it is
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

    def create_where_string(key, value)
      " AND object->>'#{key}' ~* '#{value}'"
    end
  end
end
