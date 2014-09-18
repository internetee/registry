class Admin::ContactsController < ApplicationController
  before_action :set_contact, only: [:show]

  def index
    @q = Contact.search(params[:q])
    @contacts = @q.result.page(params[:page])
  end

  def search
    render json: Contact.search_by_query(params[:q])
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end
end
