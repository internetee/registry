class Client::ContactsController < ClientController

  # TODO: Add Registrar to Contacts and search only contacts that belong to this domain
  def search
    render json: Contact.search_by_query(params[:q])
  end
end
