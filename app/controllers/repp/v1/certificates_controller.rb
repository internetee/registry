module Repp
  module V1
    class CertificatesController < BaseController
      THROTTLED_ACTIONS = %i[create].freeze
      include Shunter::Integration::Throttle

      api :POST, '/repp/v1/certificates'
      desc 'Submit a new api user certificate signing request'
      def create
        authorize! :create, Certificate
        @api_user = current_user.registrar.api_users.find(cert_params[:api_user_id])

        csr = decode_cert_params(cert_params[:csr])

        @certificate = @api_user.certificates.build(csr: csr)
        unless @certificate.save
          handle_non_epp_errors(@certificate)
          return
        end

        notify_admins
        render_success(data: { api_user: { id: @api_user.id } })
      end

      private

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
          CertificateMailer.new_certificate_signing_request(email: email,
                                                            api_user: @api_user,
                                                            csr: @certificate)
                           .deliver_now
        end
      end
    end
  end
end
