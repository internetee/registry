module Admin
  class DomainVersionsController < BaseController
    include ObjectVersionsHelper

    load_and_authorize_resource

    def index
      params[:q] ||= {}

      @q = DomainVersion.includes(:item).search(params[:q])
      @versions = @q.result.page(params[:page])
      search_params = params[:q].deep_dup

      if search_params[:registrant].present?
        registrants = Contact.where('name ilike ?', "%#{search_params[:registrant].strip}%")
        search_params.delete(:registrant)
      end

      if search_params[:registrar].present?
        registrars = Registrar.where('name ilike ?', "%#{search_params[:registrar].strip}%")
        search_params.delete(:registrar)
      end

      whereS = '1=1'

      search_params.each do |key, value|
        next if value.empty?

        whereS += case key
                  when 'event'
                    " AND event = '#{value}'"
                  when 'name'
                    " AND (object->>'name' ~* '#{value}' OR object_changes->>'name' ~* '#{value}')"
                  else
                    create_where_string(key, value)
                  end
      end

      whereS += "  AND object->>'registrant_id' IN (#{registrants.map { |r| "'#{r.id}'" }.join ','})" if registrants.present?
      whereS += '  AND 1=0' if registrants == []
      whereS += "  AND object->>'registrar_id' IN (#{registrars.map { |r| "'#{r.id}'" }.join ','})" if registrars.present?
      whereS += '  AND 1=0' if registrars == []

      versions = DomainVersion.includes(:item).where(whereS).order(created_at: :desc, id: :desc)
      @q = versions.search(params[:q])
      @versions = @q.result.page(params[:page])
      @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?
      render 'admin/domain_versions/archive'
    end

    def show
      per_page = 7
      @version = DomainVersion.find(params[:id])
      @versions = DomainVersion.where(item_id: @version.item_id).order(created_at: :desc, id: :desc)
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
      render json: DomainVersion.search_by_query(params[:q])
    end

    def create_where_string(key, value)
      " AND object->>'#{key}' ~* '#{value}'"
    end
  end
end
