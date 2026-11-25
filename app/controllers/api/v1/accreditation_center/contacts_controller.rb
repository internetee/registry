require 'serializers/repp/contact'

module Api
  module V1
    module AccreditationCenter
      class ContactsController < BaseController
        api :GET, 'api/v1/accreditation_center/contacts/:id'
        desc 'get contact by id'
        def show
          @contact = Contact.find_by(code: params[:id])

          if @contact
            render_success(data: { contact: Serializers::Repp::Contact.new(@contact, show_address: false).to_json })
          else
            render_error('Contact not found', :not_found)
          end
        end
      end
    end
  end
end
