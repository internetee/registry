module Repp
  class DomainV1 < Grape::API
    version 'v1', using: :path

    resource :domains do
      desc 'Return list of domains'
      params do
        optional :limit, type: Integer, values: (1..200).to_a, desc: 'How many domains to show'
        optional :offset, type: Integer, desc: 'Domain number to start at'
        optional :details, type: String, values: %w(true false), desc: 'Whether to include details'
      end

      get '/' do
        limit = params[:limit] || 200
        offset = params[:offset] || 0

        if params[:details] == 'true'
          domains = current_user.registrar.domains.limit(limit).offset(offset)
        else
          domains = current_user.registrar.domains.limit(limit).offset(offset).pluck(:name)
        end

        @response = {
          domains: domains,
          total_number_of_records: current_user.registrar.domains.count
        }
      end

      # example: curl -u registrar1:password localhost:3000/repp/v1/domains/1/transfer_info -H "Auth-Code: authinfopw1"
      get '/:id/transfer_info' do

        domain = Domain.where("name = ? OR id=?", params[:id], params[:id]).where(auth_info: request.headers['Auth-Code']).first
        error! I18n.t('errors.messages.epp_domain_not_found'), 401 unless domain

        contact_repp_json = proc{|contact|
          contact.attributes.slice("code", "ident_type", "ident_country_code", "phone", "email", "street", "city", "zip","country_code", "statuses")
        }

        @response = {
          domain: domain.name,
          registrant: contact_repp_json.call(domain.registrant),
          admin_contacts: domain.admin_contacts.map{|e| contact_repp_json.call(e)},
          tech_contacts: domain.tech_contacts.map{|e| contact_repp_json.call(e)}
        }
      end
    end
  end
end
