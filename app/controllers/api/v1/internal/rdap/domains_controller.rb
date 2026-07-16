require 'serializers/rdap/domain'

module Api
  module V1
    module Internal
      module Rdap
        class DomainsController < BaseController
          def show
            name = params[:name].to_s
            domain = Domain
                     .where(name: name).or(Domain.where(name_puny: name))
                     .includes(:registrant, :admin_contacts, :tech_contacts,
                               :registrar, :nameservers, :dnskeys)
                     .first

            if domain
              render json: Serializers::Rdap::Domain.new(domain).as_json, status: :ok
            else
              render_error('Domain not found', :not_found)
            end
          end
        end
      end
    end
  end
end
