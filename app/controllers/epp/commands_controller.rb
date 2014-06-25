class Epp::CommandsController < ApplicationController
  include Epp::Common

  private
  def create
    render '/epp/domains/create'
  end
end
