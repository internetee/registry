module Repp
  module V1
    module Domains
      class BaseContactsController < BaseController
        before_action :set_contacts, only: [:update]

        def set_contacts
          contacts = current_user.registrar.contacts
          @current_contact = contacts.find_by!(code: contact_params[:current_contact_id])
          @new_contact = contacts.find_by!(code: contact_params[:new_contact_id])
        end

        def update
          authorize! :manage, :repp
          @epp_errors ||= ActiveModel::Errors.new(self)
          return unless @new_contact.invalid?

          @epp_errors.add(:epp_errors,
                          msg: 'New contact must be valid',
                          code: '2304')
        end

        private

        def contact_params
          param_list = %i[current_contact_id new_contact_id]
          params.require(param_list)
          params.permit(:current_contact_id, :new_contact_id,
                        contact: {},
                        admin_contact: [param_list])
        end
      end
    end
  end
end
