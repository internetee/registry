class Registrar
  class XmlConsolesController < DeppController
    PREFS = %w[
      domain-ee
      contact-ee
      eis
      epp-ee
    ].freeze

    authorize_resource class: false

    def show; end

    def create
      begin
        @result = depp_current_user.server.request(params[:payload])
      rescue StandardError
        @result = 'CONNECTION ERROR - Is the EPP server running?'
      end
      render :show
    end

    def load_xml
      cl_trid = "#{depp_current_user.tag}-#{Time.zone.now.to_i}"
      xml_dir_path = Rails.root + 'app/views/registrar/xml_consoles/epp_requests'
      xml = File.read("#{xml_dir_path}/#{params[:obj]}/#{params[:epp_action]}.xml")
      xml = prepare_payload(xml, cl_trid)

      render plain: xml
    end

    protected

    def prepare_payload(xml, cl_trid)
      PREFS.map do |pref|
        xml.gsub!('"' + pref.to_s + '"',
                  "\"#{Xsd::Schema.filename(for_prefix: pref.to_s)}\"")
      end

      xml.gsub!('<clTRID>ABC-12345</clTRID>', "<clTRID>#{cl_trid}</clTRID>")
      xml
    end
  end
end
