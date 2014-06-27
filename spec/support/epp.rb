module Epp
  def read_body filename
    File.read("spec/epp/requests/#{filename}")
  end

  # handles connection and login automatically
  def epp_request filename
    res = Nokogiri::XML(server.request(read_body(filename)))
    parse_response(res)
  end

  def epp_plain_request filename
    res = Nokogiri::XML(server.send_request(read_body(filename)))
    parse_response(res)
  end

  def parse_response res
    {
      result_code: res.css('epp response result').first[:code],
      msg: res.css('epp response result msg').text,
      clTRID: res.css('epp trID clTRID').text
    }
  end

end

RSpec.configure do |c|
  c.include Epp, epp: true
end
