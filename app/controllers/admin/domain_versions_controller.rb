class Admin::DomainVersionsController < AdminController
  load_and_authorize_resource

  def index
    params[:q] ||= {}

    @q = DomainVersion.includes(:item).search(params[:q])
    @versions = @q.result.page(params[:page])
    search_params = params[:q].deep_dup

    if search_params[:registrant]
      registrant = Contact.find_by(name: search_params[:registrant].strip)
      search_params.delete(:registrant)
    end

    if search_params[:registrar]
      registrar = Registrar.find_by(name: search_params[:registrar].strip)
      search_params.delete(:registrar)
    end

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

    whereS += "  AND object->>'registrant_id' = '#{registrant.id}'" if registrant
    whereS += "  AND object->>'registrar_id' = '#{registrar.id}'" if registrar

    versions = DomainVersion.includes(:item).where(whereS)
    @q = versions.search(params[:q])
    @versions = @q.result.page(params[:page])
    @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i > 0
    render "admin/domain_versions/archive"

  end

  def show
    per_page = 7
    @version = DomainVersion.find(params[:id])
    @q = DomainVersion.where(item_id: @version.item_id).order(created_at: :desc).search
    @versions = @q.result.page(params[:page])
    @versions = @versions.per(per_page)
  end

  def search
    render json: DomainVersion.search_by_query(params[:q])
  end

  def create_where_string(key, value)
    " AND object->>'#{key}' ~ '#{value}'"
  end


end
