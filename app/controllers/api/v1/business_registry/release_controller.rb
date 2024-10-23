module Api
  module V1
    module BusinessRegistry
      class ReleaseController < BaseController
        before_action :authenticate, only: [:destroy]
        before_action :find_reserved_domain, only: [:destroy]
        before_action :find_reserved_domain_status, only: [:destroy]

        def destroy
          if @reserved_domain_status.destroy
            @reserved_domain.destroy if @reserved_domain

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
