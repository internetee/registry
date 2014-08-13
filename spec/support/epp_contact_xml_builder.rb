module EppContactXmlBuilder
  
  def contact_check_xml(xml_params={})

    xml_params[:ids] = xml_params[:ids] || [ { id: 'check-1234' }, { id: 'check-4321' } ]  

    xml = Builder::XmlMarkup.new

    xml.instruct!(:xml, standalone: 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.check do
          xml.tag!('contact:check', 'xmlns:contact' => 'urn:ietf:params:xml:ns:contact-1.0') do
            unless xml_params[:ids] == [false]
              xml_params[:ids].each do |x|
                xml.tag!('contact:id', x[:id])
              end
            end
          end
        end
        xml.clTRID 'ABC-12345'
      end
    end
  end


end

RSpec.configure do |c|
  c.include EppContactXmlBuilder
end
