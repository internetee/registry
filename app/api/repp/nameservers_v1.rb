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
              requires :ipv4, type: Array
              requires :ipv6, type: Array
            end
          end
        end

        old_nameserver = current_user.registrar.nameservers.find_by(hostname: params[:data][:id])
        error!({ errors: [{ title: "Hostname #{params[:data][:id]} does not exist" }] }, 404) unless old_nameserver

        new_nameserver = old_nameserver.dup
        new_nameserver.hostname = params[:data][:attributes][:hostname]
        new_nameserver.ipv4 = params[:data][:attributes][:ipv4]
        new_nameserver.ipv6 = params[:data][:attributes][:ipv6]

        error!({ errors: [{ title: 'Invalid params' }] }, 400) unless new_nameserver.valid?

        current_user.registrar.replace_nameserver(old_nameserver, new_nameserver)

        status 200
        @response = { data: { type: 'nameserver',
                              id: new_nameserver.hostname, attributes: params[:data][:attributes] } }
      end
    end
  end
end
