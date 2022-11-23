module Repp
  module V1
    module Registrar
      class XmlConsoleController < BaseController
        include EppRequestable

        PREFS = %w[
          domain-ee
          contact-ee
          eis
          epp-ee
        ].freeze

        def load_xml
          cl_trid = "#{current_user.username}-#{Time.zone.now.to_i}"
          xml_dir_path = Rails.root.join('app/views/epp/sample_requests').to_s
          xml = File.read("#{xml_dir_path}/#{params[:obj]}/#{params[:epp_action]}.xml")
          xml = prepare_payload(xml, cl_trid)

          render_success(data: { xml: xml })
        end

        private

        def prepare_payload(xml, cl_trid)
          PREFS.map do |pref|
            xml = load_schema_by_prefix(pref, xml)
          end

          xml.gsub!('<clTRID>ABC-12345</clTRID>', "<clTRID>#{cl_trid}</clTRID>")
          xml
        end

        def load_schema_by_prefix(pref, xml)
          case pref
          when 'epp-ee'
            insert_prefix_and_version(xml, pref, '1.0')
          when 'eis'
            insert_prefix_and_version(xml, pref, '1.0')
          when 'contact-ee'
            insert_prefix_and_version(xml, pref, '1.1')
          else
            insert_prefix_and_version(xml, pref, '1.2')
          end
        end

        def insert_prefix_and_version(xml, pref, version)
          xml.gsub!("\"#{pref}\"",
                    "\"#{Xsd::Schema.filename(for_prefix: pref.to_s, for_version: version)}\"")
          xml
        end
      end
    end
  end
end