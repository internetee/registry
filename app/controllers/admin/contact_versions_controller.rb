module Admin
  class ContactVersionsController < BaseController
    include ObjectVersionsHelper
    include Auditable

    load_and_authorize_resource class: 'Audit::ContactHistory'

    def index
      params[:q] ||= {}

      @q = Audit::ContactHistory.search(params[:q])
      @versions = @q.result.page(params[:page])
      return unless params[:results_per_page].to_i.positive?

      @versions = @versions.per(params[:results_per_page])
    end

    def show
      generate_show(Audit::ContactHistory)
    end

    def search
      render json: Audit::ContactHistory.search_by_query(params[:q])
    end
  end
end
