# frozen_string_literal: true

module Eeid
  module Webhooks
    # Controller for handling eeID identification requests webhook
    class IdentificationRequestsController < ActionController::Base
      skip_before_action :verify_authenticity_token

      THROTTLED_ACTIONS = %i[create].freeze
      include Shunter::Integration::Throttle

      rescue_from Shunter::ThrottleError, with: :handle_throttle_error

      # POST /eeid/webhooks/identification_requests
      def create
        return render_unauthorized unless ip_whitelisted?
        return render_invalid_signature unless valid_hmac_signature?(request.headers['X-HMAC-Signature'])

        verify_contact(permitted_params[:reference])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        handle_error(e)
      end

      private

      def permitted_params
        params.permit(:identification_request_id, :reference, :client_id)
      end

      def render_unauthorized
        render json: { error: "IPAddress #{request.remote_ip} not authorized" }, status: :unauthorized
      end

      def render_invalid_signature
        render json: { error: 'Invalid HMAC signature' }, status: :unauthorized
      end

      def valid_hmac_signature?(hmac_signature)
        secret = ENV['ident_service_client_secret']
        computed_signature = OpenSSL::HMAC.hexdigest('SHA256', secret, request.raw_post)
        ActiveSupport::SecurityUtils.secure_compare(computed_signature, hmac_signature)
      end

      def verify_contact(ref)
        contact = Contact.find_by_code(ref)

        if contact&.ident_request_sent_at.present?
          contact.update(verified_at: Time.zone.now)
          Rails.logger.info("Contact verified: #{ref}")
        else
          Rails.logger.error("Valid contact not found for reference: #{ref}")
        end
      end

      def ip_whitelisted?
        allowed_ips = ENV['webhook_allowed_ips'].to_s.split(',').map(&:strip)

        allowed_ips.include?(request.remote_ip) || Rails.env.development?
      end

      # Mock throttled_user using request IP
      def throttled_user
        # Create a mock user-like object with the request IP
        OpenStruct.new(id: request.remote_ip, class: 'WebhookRequest')
      end

      def handle_error(error)
        Rails.logger.error("Error handling webhook: #{error.message}")
        render json: { error: 'Internal Server Error' }, status: :internal_server_error
      end

      def handle_throttle_error
        render json: { error: Shunter.default_error_message }, status: :bad_request
      end
    end
  end
end
