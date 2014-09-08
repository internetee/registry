class Admin::ContactsController < ApplicationController
  def search
    c = Contact.arel_table
    query_string = "%#{params[:query]}%"
    render json: Contact.where(c[:code].matches(query_string)).pluck(:code)
  end
end
