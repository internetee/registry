class Registrar
  class XmlConsolesController < DeppController
    authorize_resource class: false

    def show
    end

    def create
      begin
        @result = depp_current_user.server.request(params[:payload])
      rescue
        @result = 'CONNECTION ERROR - Is the EPP server running?'
      end
      render :show
    end

    def load_xml
      cl_trid = "#{depp_current_user.tag}-#{Time.zone.now.to_i}"
      xml_dir_path = Rails.root + 'app/views/registrar/xml_consoles/epp_requests'
      xml = File.read("#{xml_dir_path}/#{params[:obj]}/#{params[:epp_action]}.xml")
      xml.gsub!('<clTRID>ABC-12345</clTRID>', "<clTRID>#{cl_trid}</clTRID>")
      render plain: xml
    end
  end
end
