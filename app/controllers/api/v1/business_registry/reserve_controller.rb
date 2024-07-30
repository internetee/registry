module Api
  module V1
    module BusinessRegistry
      class ReserveController < ::Api::V1::BaseController
        # before_action :set_cors_header
        # before_action :validate_params
        # before_action :authenticate, only: [:create]

        INITIATOR = 'business_registry'.freeze

        def create
          domain_name = params[:domain_name]&.downcase&.strip

          reserved_domain_status = ReservedDomainStatus.new(name: domain_name)
          reservied_domain = ReservedDomain.find_by(name: domain_name)

          if reservied_domain.present?
            render json: { message: "Domain already reserved" }, status: :ok
          elsif reserved_domain_status.save
            invoice_number = EisBilling::GetInvoiceNumber.call
            invoice_number = JSON.parse(invoice_number.body)['invoice_number'].to_i

            reference_no = nil
            invoice = invoice_structure(invoice_number, reference_no, reserved_domain_status.access_token)
            result = EisBilling::AddDeposits.new(invoice).call

            pared_result = JSON.parse(result.body)
            
            if result.code == "201" || result.code == "200"
              render json: { message: "Domain reserved successfully", token: reserved_domain_status.access_token, linkpay: pared_result['everypay_link'] }, status: :created
            else
              render json: { error: "Failed to reserve domain", details: pared_result }, status: :unprocessable_entity
            end
          else
            render json: { error: "Failed to reserve domain", details: reserved_domain_status.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def reservetion_domain_price
          124.00
        end

        def invoice_structure(invoice_number, reference_no, token)
          description = 'description'

          Struct.new(:total, :number, :buyer_name, :buyer_email, :description, :initiator, :reference_no, :reserved_domain_name, :token
          ).new(reservetion_domain_price, invoice_number, params[:buyer_name], params[:buyer_email], description, INITIATOR, reference_no, params[:domain_name], token)
        end

        def set_cors_header
          allowed_origins = ENV['ALLOWED_ORIGINS'].split(',')
          if allowed_origins.include?(request.headers['Origin'])
            response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
          else
            render json: { error: "Unauthorized origin" }, status: :unauthorized
          end
        end

        def validate_params
          if params[:domain_name].blank? || params[:buyer_name].blank? || params[:buyer_email].blank?
            render json: { error: "Missing required parameter: name" }, status: :bad_request
          end
        end
      end
    end
  end
end
