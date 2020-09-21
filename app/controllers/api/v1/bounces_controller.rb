module Api
  module V1
    class BouncesController < BaseController
      before_action :authenticate_shared_key

      # POST api/v1/bounces/
      def create
        return head(:bad_request) unless bounce_params[:bounce][:bouncedRecipients].any?

        BouncedMailAddress.record(bounce_params)
        head(:created)
      rescue ActionController::ParameterMissing
        head(:bad_request)
      end

      def bounce_params
        params.require(:data).require(:bounce).require(:bouncedRecipients).each do |r|
          r.require(:emailAddress)
        end

        params.require(:data)
      end
    end
  end
end
