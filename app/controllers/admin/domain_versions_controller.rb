module Admin
  class DomainVersionsController < BaseController
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

        # where_s += "  AND object->>'registrar_id' IN (#{registrars.map { |r| "'#{r.id}'" }.join ','})"
        where_s += " AND (object->>'registrar_id' IN (#{registrars.map { |r| "'#{r.id}'" }.join ','})
                     OR (object_changes @> '#{{ 'registrar_id': registrars.map(&:id) }.to_json}'))"

      end
      where_s += '  AND 1=0' if registrars == []

      versions = Version::DomainVersion.includes(:item).where(where_s).order(created_at: :desc, id: :desc)
      @q = versions.ransack(fix_date_params)
      @result = @q.result
      @versions = @result.page(params[:page])
      @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/domain_versions/archive', 'domain_history')
    end

    def show
      per_page = 7
      if params[:current]
        @domain = Domain.find(params[:domain_id] || params[:id])
        @version = nil
      else
        @version = Version::DomainVersion.find(params[:id])
        @domain = Domain.find(@version.item_id)
      end
      @versions = Version::DomainVersion.where(item_id: @domain.id).order(created_at: :desc, id: :desc)
      @versions_map = @versions.all.map(&:id)

      if params[:page].blank?
        counter = @version ? (@versions_map.index(@version.id) + 1) : 1
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
      created_at = params_copy['created_at_lteq']
      params_copy['created_at_lteq'] = Date.parse(created_at) + 1.day if created_at.present?

      params_copy
    end
  end
end
