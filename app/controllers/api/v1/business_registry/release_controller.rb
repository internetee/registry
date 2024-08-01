module Api
  module V1
    module BusinessRegistry
      class ReleaseController < ::Api::V1::BaseController
        before_action :authenticate, only: [:destroy]

        include Concerns::CorsHeaders
        include Concerns::TokenAuthentication

        def destroy
          if @reserved_domain_status.destroy
            EisBilling::SendReservedDomainCancellationInvoiceStatus.new(domain_name: @reserved_domain_status.name, token: @reserved_domain_status.access_token).call
            render json: { message: "Domain '#{@reserved_domain_status.name}' has been successfully released" }, status: :ok
          else
            render json: { error: "Failed to release domain", details: @reserved_domain_status.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
