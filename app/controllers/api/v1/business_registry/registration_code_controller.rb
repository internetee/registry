module Api
  module V1
    module BusinessRegistry
      class RegistrationCodeController < BaseController
        before_action :authenticate, only: [:show]
        before_action :find_reserved_domain_status, only: [:show]
        skip_before_action :find_reserved_domain, only: [:show]

        def show
          puts '---'
          puts @reserved_domain_status.inspect
          puts '---'

          if @reserved_domain_status.paid?
            password = ReservedDomain.find(@reserved_domain_status.reserved_domain_id).password
            render_success({ name: 'name', registration_code: password })
          else
            render json: { error: 'Domain not paid', linkpay_url: @reserved_domain_status.linkpay_url }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
