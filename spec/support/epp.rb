module Epp
  def read_body filename
    File.read("spec/epp/requests/#{filename}")
  end

  # handles connection and login automatically
  def epp_request filename
    begin
      parse_response(server.request(read_body(filename)))
    rescue Exception => e
      e
    end
  end

  def epp_plain_request filename
    begin
      parse_response(server.send_request(read_body(filename)))
    rescue Exception => e
      e
    end
  end

  def parse_response raw
    res = Nokogiri::XML(raw)

    obj = {
      results: [],
      clTRID: res.css('epp trID clTRID').text,
      parsed: res.remove_namespaces!,
      raw: raw
    }

    res.css('epp response result').each do |x|
      obj[:results] << {result_code: x[:code], msg: x.css('msg').text}
    end

    obj[:result_code] = obj[:results][0][:result_code]
    obj[:msg] = obj[:results][0][:msg]

    obj
  end

end

RSpec.configure do |c|
  c.include Epp, epp: true
end
