require 'serializers/repp/contact'

module Api
  module V1
    module AccreditationCenter
      class ContactsController < BaseController
        def show
          @contact = Contact.find_by(code: params[:id])

          if @contact
            render json: { code: 1000, contact: Serializers::Repp::Contact.new(@contact,
                                                                               show_address: false).to_json },
                   status: :ok
          else
            render json: { errors: 'Contact not found' }, status: :not_found
          end
        end
      end
    end
  end
end
