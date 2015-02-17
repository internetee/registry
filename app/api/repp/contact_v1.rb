module Repp
  class ContactV1 < Grape::API
    version 'v1', using: :path

    resource :contacts do
      desc 'Return list of contact'
      get '/' do
        contacts = current_user.registrar.contacts.page(params[:page])
        @response = {
          contacts: contacts,
          total_pages: contacts.total_pages
        }
      end
    end
  end
end
