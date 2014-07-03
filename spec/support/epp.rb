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

    {
      result_code: res.css('epp response result').first[:code],
      msg: res.css('epp response result msg').text,
      clTRID: res.css('epp trID clTRID').text,
      parsed: res.remove_namespaces!,
      raw: raw
    }
  end

end

RSpec.configure do |c|
  c.include Epp, epp: true
end
