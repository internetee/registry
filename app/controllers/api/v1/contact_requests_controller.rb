module Api
  module V1
    class ContactRequestsController < BaseController
      before_action :authenticate_shared_key

      def create
        return head(:bad_request) if contact_request_params[:email].blank?

        contact_request = ContactRequest.save_record(contact_request_params)
        render json: contact_request, status: :created
      rescue StandardError
        head(:bad_request)
      end

      def update
        return head(:bad_request) if params[:id].blank?

        process_id(params[:id])
      end

      private

      def process_id(id)
        record = ContactRequest.find_by(id: id)
        return :not_found unless record

        record.update_record(contact_request_params)
        render json: record, status: :ok
      rescue StandardError
        head :bad_request
      end

      def contact_request_params
        params.require(:contact_request).permit(:email, :whois_record_id, :name, :status, :ip,
                                                :message_id)
      end
    end
  end
end
