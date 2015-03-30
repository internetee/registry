module Repp
  class ContactV1 < Grape::API
    version 'v1', using: :path

    resource :contacts do
      desc 'Return list of contact'
      params do
        optional :limit, type: Integer, values: (1..20).to_a
        optional :offset, type: Integer
      end

      get '/' do
        limit = params[:limit] || 20
        offset = params[:offset] || 0

        if params[:details] == 'true'
          contacts = current_user.registrar.contacts.limit(limit).offset(offset)
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
