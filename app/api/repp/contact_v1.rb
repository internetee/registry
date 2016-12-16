module Repp
  class ContactV1 < Grape::API
    version 'v1', using: :path

    resource :contacts do
      desc 'Return list of contact'
      params do
        optional :limit, type: Integer, values: (1..200).to_a, desc: 'How many contacts to show'
        optional :offset, type: Integer, desc: 'Contact number to start at'
        optional :details, type: String, values: %w(true false), desc: 'Whether to include details'
      end

      get '/' do
        limit = params[:limit] || 200
        offset = params[:offset] || 0

        if params[:details] == 'true'
          contacts = current_user.registrar.contacts.limit(limit).offset(offset)

          unless Contact.address_processing?
            attributes = Contact.attribute_names - Contact.address_attribute_names
            contacts = contacts.select(attributes)
          end
        else
          contacts = current_user.registrar.contacts.limit(limit).offset(offset).pluck(:code)
        end

        @response = {
          contacts: contacts,
          total_number_of_records: current_user.registrar.contacts.count
        }
      end
    end
  end
end
