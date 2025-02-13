module Admin
  class DomainVersionsController < BaseController
    load_and_authorize_resource class: Version::DomainVersion

    def index
      params[:q] ||= {}
      search_params = params[:q].deep_dup.except(:created_at_gteq, :created_at_lteq)
      
      conditions = []
      values = []
      
      if search_params[:registrant].present?
        registrants = Contact.where('name ilike ?', "%#{search_params[:registrant].strip}%")
        search_params.delete(:registrant)
      end

      if search_params[:registrar].present?
        registrars = Registrar.where('name ilike ?', "%#{search_params[:registrar].strip}%")
        search_params.delete(:registrar)
      end

      search_params.each do |key, value|
        next if value.empty?

        case key
        when 'event'
          conditions << 'event = ?'
          values << value
        when 'name'
          conditions << "(object->>'name' ~* ? OR object_changes->>'name' ~* ?)"
          values.concat([value, value])
        else
          conditions << "object->>? ~* ?"
          values.concat([key, value])
        end
      end

      if registrants.present?
        conditions << "object->>'registrant_id' IN (?)"
        values << registrants.map(&:id)
      elsif registrants == []
        conditions << '1=0'
      end

      if registrars.present?
        conditions << "(object->>'registrar_id' IN (?) OR object_changes @> ?)"
        values << registrars.map(&:id)
        values << { registrar_id: registrars.map(&:id) }.to_json
      elsif registrars == []
        conditions << '1=0'
      end

      where_clause = conditions.join(' AND ')
      where_clause = '1=1' if where_clause.empty?

      versions = Version::DomainVersion.includes(:item)
                                     .where(where_clause, *values)
                                     .order(created_at: :desc, id: :desc)
                                     
      @q = versions.ransack(fix_date_params)
      @result = @q.result
      @versions = @result.page(params[:page])
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
      ["object->>? ~* ?", key, value]
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
