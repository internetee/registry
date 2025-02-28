module Repp
  module V1
    module Certificates
      class P12Controller < BaseController
        load_and_authorize_resource param_method: :cert_params
        
        THROTTLED_ACTIONS = %i[create].freeze
        include Shunter::Integration::Throttle

        api :POST, '/repp/v1/certificates/p12'
        desc 'Generate a P12 certificate'
        def create
          api_user_id = cert_params[:api_user_id]
          render_error(I18n.t('errors.messages.not_found'), :not_found) and return if api_user_id.blank?

          api_user = current_user.registrar.api_users.find(api_user_id)
          interface = cert_params[:interface].presence || 'api'
          
          # Validate interface
          unless Certificate::INTERFACES.include?(interface)
            render_error(I18n.t('errors.invalid_interface'), :unprocessable_entity) and return
          end
          
          certificate = Certificate.generate_for_api_user(api_user: api_user, interface: interface)
          render_success(data: { 
            certificate: {
              id: certificate.id,
              common_name: certificate.common_name,
              expires_at: certificate.expires_at,
              interface: certificate.interface
            } 
          })
        end

        private

        def cert_params
          params.require(:certificate).permit(:api_user_id, :interface)
        end
      end
    end
  end
end
