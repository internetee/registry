class Epp::ErrorsController < ApplicationController
  include Epp::Common

  def error
    @errors = []
    @errors << {code: params[:code], msg: params[:msg]}
    render '/epp/error'
  end
end
