module Repp
  class NameserversV1 < Grape::API
    version 'v1', using: :path

    resource 'registrar/nameservers' do
      put '/' do
        params do
          requires :data, type: Hash, allow_blank: false do
            requires :type, type: String, allow_blank: false
            requires :id, type: String, allow_blank: false
            requires :attributes, type: Hash, allow_blank: false do
              requires :hostname, type: String, allow_blank: false
              requires :ipv4, type: Array
              requires :ipv6, type: Array
            end
          end
        end

        hostname = params[:data][:id]

        unless current_user.registrar.nameservers.exists?(hostname: hostname)
          error!({ errors: [{ title: "Hostname #{hostname} does not exist" }] }, 404)
        end

        new_attributes = {
          hostname: params[:data][:attributes][:hostname],
          ipv4: params[:data][:attributes][:ipv4],
          ipv6: params[:data][:attributes][:ipv6],
        }

        begin
          affected_domains = current_user.registrar.replace_nameservers(hostname, new_attributes)
        rescue ActiveRecord::RecordInvalid => e
          error!({ errors: e.record.errors.full_messages.map { |error| { title: error } } }, 400)
        end

        status 200
        @response = { data: { type: 'nameserver',
                              id: params[:data][:attributes][:hostname],
                              attributes: params[:data][:attributes]},
                      affected_domains: affected_domains }
      end
    end
  end
end
