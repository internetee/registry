module EppContactXmlBuilder
  def contact_check_xml(xml_params = {})
    xml_params[:ids] = xml_params[:ids] || [{ id: 'check-1234' }, { id: 'check-4321' }]

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

  def contact_create_xml(xml_params = {})
    # xml_params[:ids] = xml_params[:ids] || [ { id: 'check-1234' }, { id: 'check-4321' } ]
    xml = Builder::XmlMarkup.new

    xml_params[:addr] = xml_params[:addr] ||  { street: '123 Example Dr.', street2: 'Suite 100', street3: nil,
                                                city: 'Megaton', sp: 'F3 ', pc: '201-33', cc: 'EE' }
    xml_params[:authInfo] = xml_params[:authInfo] || { pw: 'Aas34fq' }

    xml.instruct!(:xml, standalone: 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.create do
          xml.tag!('contact:create', 'xmlns:contact' => 'urn:ietf:params:xml:ns:contact-1.0') do
            xml.tag!('contact:id', xml_params[:id], 'sh8013') unless xml_params[:id] == false
            unless xml_params[:postalInfo] == [false]
              xml.tag!('contact:postalInfo', type: 'int') do
                xml.tag!('contact:name', ( xml_params[:name] || 'Sillius Soddus'))  unless xml_params[:name] == false
                xml.tag!('contact:org', ( xml_params[:org_name] || 'Example Inc.'))  unless xml_params[:org_name] == false
                unless xml_params[:addr] == [false]
                  xml.tag!('contact:addr') do
                    xml.tag!('contact:street', xml_params[:addr][:street]) unless xml_params[:addr][:street] == false
                    xml.tag!('contact:street', xml_params[:addr][:street2]) unless xml_params[:addr][:street2] == false
                    xml.tag!('contact:street', xml_params[:addr][:street3]) unless xml_params[:addr][:street3] == false
                    xml.tag!('contact:city', xml_params[:addr][:city]) unless xml_params[:addr][:city] == false
                    xml.tag!('contact:sp', xml_params[:addr][:sp]) unless xml_params[:addr][:sp] == false
                    xml.tag!('contact:pc', xml_params[:addr][:pc]) unless xml_params[:addr][:pc] == false
                    xml.tag!('contact:cc', xml_params[:addr][:cc]) unless xml_params[:addr][:cc] == false
                  end
                end
              end
            end
            xml.tag!('contact:voice', (xml_params[:voice] || '+372.1234567')) unless xml_params[:voice] == false
            xml.tag!('contact:fax', (xml_params[:fax] || '123123')) unless xml_params[:fax] == false
            xml.tag!('contact:email', (xml_params[:email] || 'example@test.example')) unless xml_params[:email] == false
            xml.tag!('contact:ident', (xml_params[:ident] || '37605030299'), type: 'op') unless xml_params[:ident] == false
            unless xml_params[:authInfo] == [false]
              xml.tag!('contact:authInfo') do
                xml.tag!('contact:pw', xml_params[:authInfo][:pw]) unless xml_params[:authInfo][:pw] == false
              end
            end
            # Disclosure logic
          end
        end
        xml.clTRID 'ABC-12345'
      end
    end
  end

  # CONTACT UPDATE NEEDS WORK USE ON YOUR OWN RISK
  def contact_update_xml(xml_params = {})
    xml = Builder::XmlMarkup.new

    # postalInfo = xml_params.try(:chg).try(:postalInfo)
    # addr = postalInfo.try(:addr)
    postalInfo = xml_params[:chg][:postalInfo] rescue nil
    addr = postalInfo[:addr] rescue nil

    unless addr
      addr = { street: 'Downtown', city: 'Stockholm', cc: 'SE' }
    end

    unless postalInfo
      postalInfo = { name: 'Jane Doe', org: 'Fake Inc.', voice: '+321.12345', fax: '12312312', addr: addr  }
    end

    xml_params[:chg] = xml_params[:chg] || { postalInfo: postalInfo }

    xml_params[:chg][:postalInfo] = postalInfo
    xml_params[:chg][:postalInfo][:addr] = addr

    xml_params[:chg][:authInfo] = xml_params[:chg][:authInfo] || { pw: 'ccds4324pok' }

    xml.instruct!(:xml, standalone: 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.update do
          xml.tag!('contact:update', 'xmlns:contact' => 'urn:ietf:params:xml:ns:contact-1.0') do
            xml.tag!('contact:id', (xml_params[:id] || 'sh8013')) unless xml_params[:id] == false
            unless xml_params[:chg] == [false]
              xml.tag!('contact:chg') do
                xml.tag!('contact:voice', xml_params[:chg][:phone] || '+123.321123') unless xml_params[:chg][:phone] == false
                xml.tag!('contact:email', xml_params[:chg][:email] || 'jane@doe.com') unless xml_params[:chg][:email] == false
                unless xml_params[:chg][:postalInfo] == false
                  xml.tag!('contact:postalInfo') do
                    xml.tag!('contact:name', xml_params[:chg][:postalInfo][:name]) unless xml_params[:chg][:postalInfo][:name] == false
                    xml.tag!('contact:org', xml_params[:chg][:postalInfo][:org]) unless xml_params[:chg][:postalInfo][:org] == false
                    unless xml_params[:chg][:postalInfo][:addr] == false
                      xml.tag!('contact:addr') do
                        xml.tag!('contact:street', xml_params[:chg][:postalInfo][:addr][:street]) unless xml_params[:chg][:postalInfo][:addr][:street] == false
                        xml.tag!('contact:street', xml_params[:chg][:postalInfo][:addr][:street2]) unless xml_params[:chg][:postalInfo][:addr][:street2] == false
                        xml.tag!('contact:street', xml_params[:chg][:postalInfo][:addr][:street3]) unless xml_params[:chg][:postalInfo][:addr][:street3] == false
                        xml.tag!('contact:city', xml_params[:chg][:postalInfo][:addr][:city]) unless xml_params[:chg][:postalInfo][:addr][:city] == false
                        xml.tag!('contact:sp', xml_params[:chg][:postalInfo][:addr][:sp]) unless xml_params[:chg][:postalInfo][:addr][:sp] == false
                        xml.tag!('contact:pc', xml_params[:chg][:postalInfo][:addr][:pc]) unless xml_params[:chg][:postalInfo][:addr][:pc] == false
                        xml.tag!('contact:cc', xml_params[:chg][:postalInfo][:addr][:cc]) unless xml_params[:chg][:postalInfo][:addr][:cc] == false
                      end
                    end
                  end
                end
                unless xml_params[:chg][:authInfo] == [false]
                  xml.tag!('contact:authInfo') do
                    xml.tag!('contact:pw', xml_params[:chg][:authInfo][:pw]) unless xml_params[:chg][:authInfo][:pw] == false
                  end
                end
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
