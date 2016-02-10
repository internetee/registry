class Admin::ContactVersionsController < AdminController
  load_and_authorize_resource

  def index
    params[:q] ||= {}

    @q = ContactVersion.search(params[:q])
    @versions = @q.result.page(params[:page])

    whereS = "1=1"

    params[:q].each do |key, value|
      next if value.empty?
      whereS += create_where_string(key, value)
    end

    versions = ContactVersion.includes(:item).where(whereS)
    @q = versions.search(params[:q])
    @versions = @q.result.page(params[:page])
    @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i > 0

  end

  def search
    render json: ContactVersion.search_by_query(params[:q])
  end

  def create_where_string(key, value)
    " AND object->>'#{key}' ~ '#{value}'"
  end

end
