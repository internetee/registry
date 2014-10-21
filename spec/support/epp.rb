module Epp
  def read_body(filename)
    File.read("spec/epp/requests/#{filename}")
  end

  # handles connection and login automatically
  def epp_request(data, *args)
    server = server_zone
    server = server_elkdata if args.include?(:elkdata)

    return parse_response(server.request(data)) if args.include?(:xml)
    return parse_response(server.request(read_body(data)))
  rescue => e
    e
  end

  def epp_plain_request(data, *args)
    server = server_gitlab
    server = server_elkdata if args.include?(:elkdata)
    server = server_zone if args.include?(:zone)

    return parse_response(server.send_request(data)) if args.include?(:xml)
    return parse_response(server.send_request(read_body(data)))
  rescue => e
    e
  end

  def parse_response(raw)
    res = Nokogiri::XML(raw)

    obj = {
      results: [],
      clTRID: res.css('epp trID clTRID').text,
      parsed: res.remove_namespaces!,
      raw: raw
    }

    res.css('epp response result').each do |x|
      obj[:results] << { result_code: x[:code], msg: x.css('msg').text, value: x.css('value > *').try(:first).try(:text) }
    end

    obj[:result_code] = obj[:results][0][:result_code]
    obj[:msg] = obj[:results][0][:msg]

    obj
  end

  # print output
  def po(r)
    puts r[:parsed].to_s
  end

  ### REQUEST TEMPLATES ###

  def domain_create_xml(xml_params = {}, dnssec_params = {})

    defaults = {
      name: { value: 'example.ee' },
      period: { value: '1', attrs: { unit: 'y' } },
      ns: [
        { hostObj: { value: 'ns1.example.net' } },
        { hostObj: { value: 'ns2.example.net' } }
      ],
      registrant: { value: 'jd1234' },
      _other: [
        { contact: { value: 'sh8013', attrs: { type: 'admin' } } },
        { contact: { value: 'sh8013', attrs: { type: 'tech' } } },
        { contact: { value: 'sh801333', attrs: { type: 'tech' } } }
      ]
    }

    xml_params = defaults.deep_merge(xml_params)

    dsnsec_defaults = {
      _other: [
        {  keyData: {
          flags: { value: '257' },
          protocol: { value: '3' },
          alg: { value: '5' },
          pubKey: { value: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8' }
        }
      }]
    }

    dnssec_params = dsnsec_defaults.deep_merge(dnssec_params) if dnssec_params != false

    xml = Builder::XmlMarkup.new

    xml.instruct!(:xml, standalone: 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.create do
          xml.tag!('domain:create', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
            generate_xml_from_hash(xml_params, xml, 'domain')
          end
        end
        xml.extension do
          xml.tag!('secDNS:create', 'xmlns:secDNS' => 'urn:ietf:params:xml:ns:secDNS-1.1') do
            generate_xml_from_hash(dnssec_params, xml, 'secDNS')
          end
        end if dnssec_params != false
        xml.clTRID 'ABC-12345'
      end
    end
  end

  def domain_renew_xml(xml_params = {})
    xml = Builder::XmlMarkup.new

    xml.instruct!(:xml, standalone: 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.renew do
          xml.tag!('domain:renew', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
            xml.tag!('domain:name', (xml_params[:name] || 'example.ee')) if xml_params[:name] != false
            xml.tag!('domain:curExpDate', (xml_params[:curExpDate] || '2014-08-07')) if xml_params[:curExpDate] != false

            if xml_params[:period] != false
              xml.tag!('domain:period', (xml_params[:period_value] || 1), 'unit' => (xml_params[:period_unit] || 'y'))
            end
          end
        end
        xml.clTRID 'ABC-12345'
      end
    end
  end

  def domain_check_xml(xml_params = {})
    xml_params[:names] = xml_params[:names] || ['example.ee']
    xml = Builder::XmlMarkup.new

    xml.instruct!(:xml, standalone: 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.check do
          xml.tag!('domain:check', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
            xml_params[:names].each do |x|
              xml.tag!('domain:name', (x || 'example.ee'))
            end if xml_params[:names].any?
          end
        end
        xml.clTRID 'ABC-12345'
      end
    end
  end

  def domain_info_xml(xml_params = {})
    defaults = {
      name: { value: 'example.ee', attrs: { hosts: 'all' } },
      authInfo: {
        pw: { value: '2fooBAR' }
      }
    }

    xml_params = defaults.deep_merge(xml_params)

    xml = Builder::XmlMarkup.new

    xml.instruct!(:xml, standalone: 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.info do
          xml.tag!('domain:info', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
            generate_xml_from_hash(xml_params, xml, 'domain')
          end
        end
        xml.clTRID 'ABC-12345'
      end
    end

  end

  def domain_update_xml(xml_params = {}, dnssec_params = false)
    defaults = {
      name: { value: 'example.ee' }
    }

    xml_params = defaults.deep_merge(xml_params)

    xml = Builder::XmlMarkup.new

    xml.instruct!(:xml, standalone: 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.update do
          xml.tag!('domain:update', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
            generate_xml_from_hash(xml_params, xml, 'domain')
          end
        end

        xml.extension do
          xml.tag!('secDNS:create', 'xmlns:secDNS' => 'urn:ietf:params:xml:ns:secDNS-1.1') do
            generate_xml_from_hash(dnssec_params, xml, 'secDNS')
          end
        end if dnssec_params != false
        xml.clTRID 'ABC-12345'
      end
    end
  end

  def generate_xml_from_hash(xml_params, xml, ns)
    xml_params.each do |k, v|
      # Value is a hash which has string type value
      if v.is_a?(Hash) && v[:value].is_a?(String)
        xml.tag!("#{ns}:#{k}", v[:value], v[:attrs])
      # Value is a hash which is nested
      elsif v.is_a?(Hash)
        xml.tag!("#{ns}:#{k}") do
          generate_xml_from_hash(v, xml, ns)
        end
      # Value is an array
      elsif v.is_a?(Array)
        if k.to_s.start_with?('_')
          v.each do |x|
            generate_xml_from_hash(x, xml, ns)
          end
        else
          xml.tag!("#{ns}:#{k}") do
            v.each do |x|
              generate_xml_from_hash(x, xml, ns)
            end
          end
        end
      end
    end
  end


  def domain_transfer_xml(xml_params = {})
    xml_params[:name] = xml_params[:name] || 'example.ee'
    xml_params[:pw] = xml_params[:pw] || '98oiewslkfkd'
    xml_params[:op] = xml_params[:op] || 'query'
    xml_params[:roid] = xml_params[:roid] || 'JD1234-REP'

    xml = Builder::XmlMarkup.new

    xml.instruct!(:xml, standalone: 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.transfer('op' => xml_params[:op]) do
          xml.tag!('domain:transfer', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
            if xml_params[:name] != false
              xml.tag!('domain:name', xml_params[:name])
            end

            xml.tag!('domain:authInfo') do
              xml.tag!('domain:pw', xml_params[:pw], 'roid' => xml_params[:roid])
            end if xml_params[:authInfo] != false
          end
        end
        xml.clTRID 'ABC-12345'
      end
    end
  end

  def domain_delete_xml(xml_params = {})
    xml_params[:name] = xml_params[:name] || 'example.ee'
    xml = Builder::XmlMarkup.new

    xml.instruct!(:xml, standalone: 'no')
    xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
      xml.command do
        xml.delete do
          xml.tag!('domain:delete', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
            if xml_params[:name] != false
              xml.tag!('domain:name', xml_params[:name])
            end
          end
        end
        xml.clTRID 'ABC-12345'
      end
    end
  end
end

RSpec.configure do |c|
  c.include Epp, epp: true
end
