module Admin
  class ContactVersionsController < BaseController
    include ObjectVersionsHelper

    load_and_authorize_resource

    def index
      params[:q] ||= {}

      @q = Audit::Contact.search(params[:q])
      @versions = @q.result.page(params[:page])
      return unless params[:results_per_page].to_i.positive?

      @versions = @versions.per(params[:results_per_page])
    end

    def show
      per_page = 7

      @version = Audit::Contact.find(params[:id])
      @versions = Audit::Contact.where(object_id: @version.object_id)
                                .order(recorded_at: :desc, id: :desc)
      @versions_map = @versions.all.map(&:id)

      # what we do is calc amount of results until needed version
      # then we cacl which page it is
      params[:page] = catch_version_page if params[:page].blank?

      @versions = @versions.page(params[:page]).per(per_page)
    end

    def search
      render json: Audit::Contact.search_by_query(params[:q])
    end
  end
end
