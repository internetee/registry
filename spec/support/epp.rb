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

  def domain_transfer_xml(xml_params = {}, op = 'query')
    defaults = {
      name: { value: 'example.ee' },
      authInfo: {
        pw: { value: '98oiewslkfkd', attrs: { roid: 'JD1234-REP' } }
      }
    }

    xml_params = defaults.deep_merge(xml_params)
    EppXml::Domain.transfer(xml_params, op)
  end
end

RSpec.configure do |c|
  c.include Epp, epp: true
end
