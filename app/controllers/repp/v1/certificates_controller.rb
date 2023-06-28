require 'serializers/repp/certificate'
module Repp
  module V1
    class CertificatesController < BaseController
      before_action :find_certificate, only: %i[show download]
      load_and_authorize_resource param_method: :cert_params

      THROTTLED_ACTIONS = %i[show create download].freeze
      include Shunter::Integration::Throttle

      api :GET, '/repp/v1/api_users/:api_user_id/certificates/:id'
      desc "Get a specific api user's specific certificate data"
      def show
        serializer = Serializers::Repp::Certificate.new(@certificate)
        render_success(data: { cert: serializer.to_json })
      end

      api :POST, '/repp/v1/certificates'
      desc 'Submit a new api user certificate signing request'
      def create
        @api_user = current_user.registrar.api_users.find(cert_params[:api_user_id])

        csr = decode_cert_params(cert_params[:csr])

        @certificate = @api_user.certificates.build(csr: csr)

        if @certificate.save
          notify_admins
          render_success(data: { api_user: { id: @api_user.id } })
        else
          handle_non_epp_errors(@certificate)
        end
      end

      api :get, '/repp/v1/api_users/:api_user_id/certificates/:id/download'
      desc "Download a specific api user's specific certificate"
      param :type, String, required: true, desc: 'Type of certificate (csr or crt)'
      def download
        filename = "#{@api_user.username}_#{Time.zone.today.strftime('%y%m%d')}_portal.#{params[:type]}.pem"
        send_data @certificate[params[:type].to_s], filename: filename
      end

      private

      def find_certificate
        @api_user = current_user.registrar.api_users.find(params[:api_user_id])
        @certificate = @api_user.certificates.find(params[:id])
      end

      def cert_params
        params.require(:certificate).permit(:api_user_id, csr: %i[body type])
      end

      def decode_cert_params(csr_params)
        return if csr_params.blank?

        Base64.decode64(csr_params[:body])
      end

      def notify_admins
        admin_users_emails = User.all.select { |u| u.roles.include? 'admin' }.pluck(:email)

        return if admin_users_emails.empty?

        admin_users_emails.each do |email|
          CertificateMailer.certificate_signing_requested(email: email,
                                                          api_user: @api_user,
                                                          csr: @certificate)
                           .deliver_now
        end
      end
    end
  end
end
