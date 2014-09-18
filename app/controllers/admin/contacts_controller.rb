class Admin::ContactsController < ApplicationController

  def index
    @q = Contact.search(params[:q])
    @contacts = @q.result.page(params[:page])
  end

  def search
    render json: Contact.search_by_query(params[:q])
  end
end
