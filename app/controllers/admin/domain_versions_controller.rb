module Admin
  class DomainVersionsController < BaseController
    include ObjectVersionsHelper

    load_and_authorize_resource class: Version::DomainVersion

    def index
      params[:q] ||= {}

      search_params = params[:q].deep_dup.except(:created_at_gteq, :created_at_lteq)

      if search_params[:registrant].present?
        registrants = Contact.where('name ilike ?', "%#{search_params[:registrant].strip}%")
        search_params.delete(:registrant)
      end

      if search_params[:registrar].present?
        registrars = Registrar.where('name ilike ?', "%#{search_params[:registrar].strip}%")
        search_params.delete(:registrar)
      end

      where_s = '1=1'

      search_params.each do |key, value|
        next if value.empty?

        where_s += case key
                   when 'event'
                     " AND event = '#{value}'"
                   when 'name'
                     " AND (object->>'name' ~* '#{value}' OR object_changes->>'name' ~* '#{value}')"
                   else
                     create_where_string(key, value)
                   end
      end

      if registrants.present?
        where_s += "  AND object->>'registrant_id' IN (#{registrants.map { |r| "'#{r.id}'" }.join ','})"
      end
      where_s += '  AND 1=0' if registrants == []
      if registrars.present?
        where_s += "  AND object->>'registrar_id' IN (#{registrars.map { |r| "'#{r.id}'" }.join ','})"
      end
      where_s += '  AND 1=0' if registrars == []

      versions = Version::DomainVersion.includes(:item).where(where_s).order(created_at: :desc, id: :desc)
      @q = versions.ransack(fix_date_params)

      @versions = @q.result.page(params[:page])
      @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/domain_versions/archive', 'domain_history')
    end

    def show
      per_page = 7
      @version = Version::DomainVersion.find(params[:id])
      @versions = Version::DomainVersion.where(item_id: @version.item_id).order(created_at: :desc, id: :desc)
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
      render json: Version::DomainVersion.search_by_query(params[:q])
    end

    def create_where_string(key, value)
      " AND object->>'#{key}' ~* '#{value}'"
    end

    private

    def fix_date_params
      params_copy = params[:q].deep_dup
      if params_copy['created_at_lteq'].present?
        params_copy['created_at_lteq'] = Date.parse(params_copy['created_at_lteq']) + 1.day
      end

      params_copy
    end

    def render_by_format(page, filename)
      respond_to do |format|
        format.html { render page }
        format.csv do
          raw_csv = csv_generate
          send_data raw_csv,
                    filename: "#{filename}_#{Time.zone.now.to_formatted_s(:number)}.csv",
                    type: "#{Mime[:csv]}; charset=utf-8"
        end
      end
    end
  end
end
