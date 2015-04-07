module Depp
  class XmlConsolesController < ApplicationController
    def show; end

    def create
      begin
        @result = depp_current_user.server.request(params[:payload])
      rescue
        @result = 'CONNECTION ERROR - Is the EPP server running?'
      end
      render :show
    end

    def load_xml
      # binding.pry
      cl_trid = "#{depp_current_user.tag}-#{Time.now.to_i}"
      xml_dir_path = Depp::Engine.root + 'app/views/depp/xml_consoles/epp_requests'
      xml = File.read("#{xml_dir_path}/#{params[:obj]}/#{params[:epp_action]}.xml")
      xml.gsub!('<clTRID>ABC-12345</clTRID>', "<clTRID>#{cl_trid}</clTRID>")
      render text: xml
    end
  end
end
