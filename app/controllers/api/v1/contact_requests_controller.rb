module Api
  module V1
    class ContactRequestsController < BaseController
      before_action :authenticate_shared_key

      # POST api/v1/contact_requests/
      def create
        return head(:bad_request) if contact_request_params[:email].blank?

        ContactRequest.save_record(contact_request_params)
        head(:created)
      rescue StandardError
        head(:bad_request)
      end

      def update
        return head(:bad_request) if params[:id].blank?

        record = ContactRequest.find_by(id: params[:id])
        return head(:not_found) unless record

        record.update_status(contact_request_params[:status])
        head(:ok)
      rescue StandardError
        head(:bad_request)
      end

      def contact_request_params
        params.require(:contact_request).permit(:email, :whois_record_id, :name, :status)
      end
    end
  end
end
