module Repp
  module V1
    class WhiteIpsController < BaseController
      before_action :find_white_ip, only: %i[show update destroy]
      load_and_authorize_resource

      THROTTLED_ACTIONS = %i[index show create update destroy].freeze
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

        notify_admins if @white_ip.interfaces.include? WhiteIp::API
        render_success(data: { ip: { id: @white_ip.id } })
      end

      api :PUT, '/repp/v1/white_ips/:id'
      desc 'Update whitelisted IP address'
      def update
        api = @white_ip.interfaces.include? WhiteIp::API
        unless @white_ip.update(white_ip_params)
          handle_non_epp_errors(@white_ip)
          return
        end

        notify_admins if @white_ip.interfaces.include? WhiteIp::API
        notify_admins if api && !@white_ip.interfaces.include?(WhiteIp::API)
        render_success(data: { ip: { id: @white_ip.id } })
      end

      api :DELETE, '/repp/v1/white_ips/:id'
      desc 'Delete a specific whitelisted IP address'
      def destroy
        ip = @white_ip
        unless @white_ip.destroy
          handle_non_epp_errors(@white_ip)
          return
        end

        notify_admins(ip: ip, action: 'deleted') if ip.interfaces.include?(WhiteIp::API)
        render_success
      end

      private

      def find_white_ip
        @white_ip = current_user.registrar.white_ips.find(params[:id])
      end

      def white_ip_params
        params.require(:white_ip).permit(:address, interfaces: [])
      end

      def notify_admins(ip: @white_ip, action: 'updated')
        admin_users_emails = User.admin.pluck(:email).reject(&:blank?)

        return if admin_users_emails.empty?

        admin_users_emails.each do |email|
          WhiteIpMailer.with(email: email, api_user: current_user,
                             white_ip: ip)
                       .send("api_ip_address_#{action}")
                       .deliver_now
        end
      end
    end
  end
end
