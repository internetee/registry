class Admin::RegistrarsController < ApplicationController
  def search
    render json: Registrar.search_by_query(params[:query])
  end
end
