module Epp::Common
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :null_session
  end

  def proxy
    send(params[:command])
  end

  def parsed_frame
    Nokogiri::XML(params[:frame]).remove_namespaces!
  end

  def error
    render 'error'
  end
end
