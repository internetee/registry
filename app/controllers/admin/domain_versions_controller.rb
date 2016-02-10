class Admin::DomainVersionsController < AdminController
  load_and_authorize_resource

  def index
    params[:q] ||= {}

    @q = DomainVersion.includes(:item).search(params[:q])
    @versions = @q.result.page(params[:page])
    search_params = params[:q].deep_dup

    if search_params[:registrant]
      registrant = Contact.find_by_name(search_params[:registrant])
      search_params.delete(:registrant)
    end

    if search_params[:registrar]
      registrar = Registrar.find_by_name(search_params[:registrar])
      search_params.delete(:registrar)
    end

    whereS = "1=1"

    search_params.each do |key, value|
      next if value.empty?
      whereS += create_where_string(key, value)
    end

    whereS += "  AND object->>'registrant_id' ~ '#{registrant.id}'" if registrant
    whereS += "  AND object->>'registrar_id' ~ '#{registrar.id}'" if registrar

    versions = DomainVersion.includes(:item).where(whereS)
    @q = versions.search(params[:q])
    @versions = @q.result.page(params[:page])
    @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i > 0
    render "admin/domain_versions/archive"

  end

  def search
    render json: DomainVersion.search_by_query(params[:q])
  end

  def create_where_string(key, value)
    " AND object->>'#{key}' ~ '#{value}'"
  end


end
