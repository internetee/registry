class Admin::DomainVersionsController < AdminController
  load_and_authorize_resource

  def index
    params[:q] ||= {}

    @q = DomainVersion.includes(:item).search(params[:q])
    @versions = @q.result.page(params[:page])
    search_params = params[:q].deep_dup

    if search_params[:registrant].present?
      registrants = Contact.where("name like ?", "%#{search_params[:registrant].strip}%")
      search_params.delete(:registrant)
    end

    if search_params[:registrar].present?
      registrars = Registrar.where("name like ?", "%#{search_params[:registrar].strip}%")
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

    whereS += "  AND object->>'registrant_id' IN (#{registrants.map { |r| "'#{r.id.to_s}'" }.join ','})" if registrants
    whereS += "  AND object->>'registrar_id' IN (#{registrars.map { |r| "'#{r.id.to_s}'" }.join ','})" if registrars

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

    if (@q.result.count > per_page) && params[:page] == 'default'
      page = 1
      @q.result.each_with_index do |v, i|
        break if v.id == @version.id and page = (i / per_page) + 1
      end
      params[:page] = page
      @versions = @q.result.page(page)
    else
      @versions = @q.result.page(params[:page])
    end

    @versions = @versions.per(per_page)
  end

  def search
    render json: DomainVersion.search_by_query(params[:q])
  end

  def create_where_string(key, value)
    " AND object->>'#{key}' ~ '#{value}'"
  end


end
