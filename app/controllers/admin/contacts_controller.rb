class Admin::ContactsController < ApplicationController
  def search
    render json: Contact.search_by_query(params[:q])
  end
end
