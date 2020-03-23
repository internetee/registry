module Admin
  class DomainVersionsController < BaseController
    include ObjectVersionsHelper

    load_and_authorize_resource

    def index
      params[:q] ||= {}

      @q = Audit::Domain.search(params[:q])
      @versions = @q.result.page(params[:page])
      search_params = params[:q].deep_dup

      if search_params[:registrant].present?
        registrants = Contact.where("name ilike ?", "%#{search_params[:registrant].strip}%")
        search_params.delete(:registrant)
      end

      if search_params[:registrar].present?
        registrars = Registrar.where("name ilike ?", "%#{search_params[:registrar].strip}%")
        search_params.delete(:registrar)
      end

      whereS = "1=1"

      search_params.each do |key, value|
        next if value.empty?

        whereS += case key
                  when 'action'
                    " AND action = '#{value}'"
                  when 'name'
                    " AND (new_value->>'name' ~* '#{value}' OR new_value->>'name' ~* '#{value}')"
                  else
                    create_where_string(key, value)
                  end
      end

      whereS += "  AND new_value->>'registrant_id' IN (#{registrants.map { |r| "'#{r.id.to_s}'" }.join ','})" if registrants.present?
      whereS += "  AND 1=0" if registrants == []
      whereS += "  AND new_value->>'registrar_id' IN (#{registrars.map { |r| "'#{r.id.to_s}'" }.join ','})" if registrars.present?
      whereS += "  AND 1=0" if registrars == []

      versions = Audit::Domain.where(whereS).order(recorded_at: :desc, id: :desc)
      @q = versions.search(params[:q])
      @versions = @q.result.page(params[:page])
      @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?
      render "admin/domain_versions/archive"

    end

    def show
      per_page = 7
      @version = Audit::Domain.find(params[:id])
      @versions = Audit::Domain.where(object_id: @version.object_id)
                               .order(recorded_at: :desc, id: :desc)
      @versions_map = @versions.all.map(&:id)

      # what we do is calc amount of results until needed version
      # then we cacl which page it is
      params[:page] = catch_version_page if params[:page].blank?

      @versions = @versions.page(params[:page]).per(per_page)
    end

    def search
      render json: Audit::Domain.search_by_query(params[:q])
    end

    def create_where_string(key, value)
      " AND object->>'#{key}' ~* '#{value}'"
    end
  end
end
