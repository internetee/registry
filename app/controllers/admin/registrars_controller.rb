class Admin::RegistrarsController < ApplicationController
  def search
    r = Registrar.arel_table
    query_string = "%#{params[:query]}%"
    render json: Registrar.where(r[:name].matches(query_string)).pluck(:name)
  end
end
