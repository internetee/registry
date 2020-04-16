module Admin
  class DomainVersionsController < BaseController
    include ObjectVersionsHelper
    include Auditable

    load_and_authorize_resource class: 'Audit::DomainHistory'

    def index
      params[:q] ||= {}

      @q = Audit::DomainHistory.search(params[:q])
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

      where_str = '1=1'

      search_params.each do |key, value|
        next if value.empty?

        where_str += case key
                     when 'action'
                       " AND action = '#{value}'"
                     when 'name'
                       " AND (new_value->>'name' ~* '#{value}' OR new_value->>'name' ~* '#{value}')"
                     else
                       create_where_string(key, value)
                     end
      end

      where_str += add_query(contacts: registrants, field: 'registrant_id') if registrants.present?
      where_str += '  AND 1=0' if registrants == []
      where_str += add_query(contacts: registrars, field: 'registrar_id') if registrars.present?
      where_str += '  AND 1=0' if registrars == []

      versions = Audit::DomainHistory.where(where_str).order(recorded_at: :desc, id: :desc)
      @q = versions.search(params[:q])
      @versions = @q.result.page(params[:page])
      @versions = @versions.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?
      render 'admin/domain_versions/archive'
    end

    def show
      generate_show(Audit::DomainHistory)
    end

    def add_query(contacts:, field:)
      "  AND (new_value->>#{field} IN (#{contacts.map { |r| "'#{r.id.to_s}'" }.join ','})"\
      " OR old_value->>#{field} IN (#{contacts.map { |r| "'#{r.id.to_s}'" }.join ','}))"
    end

    def search
      render json: Audit::DomainHistory.search_by_query(params[:q])
    end

    def create_where_string(key, value)
      " AND (new_value->>'#{key}' ~* '#{value}' OR old_value->>'#{key}' ~* '#{value}')"
    end
  end
end
