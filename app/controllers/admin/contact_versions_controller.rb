module Admin
  class ContactVersionsController < BaseController
    include ObjectVersionsHelper

    load_and_authorize_resource

    def index
      params[:q] ||= {}

      @q = Audit::Contact.search(params[:q])
      @versions = @q.result.page(params[:page])
      @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?
    end

    def show
      per_page = 7

      @version = Audit::Contact.find(params[:id])
      @versions = Audit::Contact.where(object_id: @version.object_id).order(recorded_at: :desc, id: :desc)
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
      render json: Audit::Contact.search_by_query(params[:q])
    end
  end
end
