module Repp
  module V1
    module Domains
      class BaseContactsController < BaseController
        before_action :set_current_contact, only: [:update]
        before_action :set_new_contact, only: [:update]

        def set_current_contact
          @current_contact = current_user.registrar.contacts
                                         .find_by!(code: contact_params[:current_contact_id])
        end

        def set_new_contact
          @new_contact = current_user.registrar.contacts.find_by!(code: params[:new_contact_id])
        end

        def update
          @epp_errors ||= ActiveModel::Errors.new(self)
          if @new_contact.invalid?
            @epp_errors.add(:epp_errors,
                            msg: 'New contact must be valid',
                            code: '2304')
          end
        end

        private

        def contact_params
          params.require(%i[current_contact_id new_contact_id])
          params.permit(:current_contact_id, :new_contact_id)
        end
      end
    end
  end
end
