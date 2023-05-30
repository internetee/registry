module Repp
  module V1
    class WhiteIpsController < BaseController
      load_and_authorize_resource

      THROTTLED_ACTIONS = %i[index create update destroy].freeze
      include Shunter::Integration::Throttle

      api :GET, '/repp/v1/white_ips'
      desc 'Get all whitelisted IPs'
      def index
        ips = current_user.registrar.white_ips

        render_success(data: { ips: ips.as_json,
                               count: ips.count })
      end

      api :GET, '/repp/v1/white_ips/:id'
      desc 'Get a specific whitelisted IP address'
      def show
        render_success(data: { ip: @white_ip.as_json, interfaces: WhiteIp::INTERFACES })
      end

      api :POST, '/repp/v1/white_ips'
      desc 'Add new whitelisted IP'
      def create
        @white_ip = current_user.registrar.white_ips.build(white_ip_params)
        unless @white_ip.save
          handle_non_epp_errors(@white_ip)
          return
        end

        render_success(data: { ip: { id: @white_ip.id } })
      end

      api :PUT, '/repp/v1/white_ips/:id'
      desc 'Update whitelisted IP address'
      def update
        unless @white_ip.update(white_ip_params)
          handle_non_epp_errors(@white_ip)
          return
        end

        render_success(data: { ip: { id: @white_ip.id } })
      end

      api :DELETE, '/repp/v1/white_ips/:id'
      desc 'Delete a specific whitelisted IP address'
      def destroy
        unless @white_ip.destroy
          handle_non_epp_errors(@white_ip)
          return
        end

        render_success
      end

      private

      def white_ip_params
        params.require(:white_ip).permit(:id, :ipv4, :ipv6, interfaces: [])
      end
    end
  end
end
