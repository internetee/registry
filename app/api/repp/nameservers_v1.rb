module Repp
  class NameserversV1 < Grape::API
    version 'v1', using: :path

    resource :nameservers do
      put '/' do
        params do
          requires :data, type: Hash do
            requires :type, type: String, allow_blank: false
            requires :id, type: String, allow_blank: false
            requires :attributes, type: Hash do
              requires :hostname, type: String, allow_blank: false
            end
          end
        end

        current_user.registrar.nameservers.where(hostname: params[:data][:id]).each do |nameserver|
          nameserver.hostname = params[:data][:attributes][:hostname]
          nameserver.ipv4 = params[:data][:attributes][:ipv4]
          nameserver.ipv6 = params[:data][:attributes][:ipv6]
          nameserver.save!
        end

        status 204
        body false
        @response = {}
      end
    end
  end
end
