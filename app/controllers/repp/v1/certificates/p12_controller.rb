module Repp
  module V1
    module Certificates
      class P12Controller < BaseController
        load_and_authorize_resource class: 'Certificate', param_method: :p12_params
        
        THROTTLED_ACTIONS = %i[create].freeze
        include Shunter::Integration::Throttle

        api :POST, '/repp/v1/certificates/p12'
        desc 'Generate a P12 certificate'
        def create
          api_user_id = p12_params[:api_user_id]
          render_error(I18n.t('errors.messages.not_found'), :not_found) and return if api_user_id.blank?

          api_user = current_user.registrar.api_users.find(api_user_id)
          certificate = Certificate.generate_for_api_user(api_user: api_user)
          render_success(data: { certificate: certificate })
        end

        private

        def p12_params
          params.require(:p12).permit(:api_user_id)
        end
      end
    end
  end
end