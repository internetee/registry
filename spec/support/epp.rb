module Epp
  def read_body filename
    File.read("spec/epp/requests/#{filename}")
  end

  def epp_request filename
    response = Nokogiri::XML(server.send_request(read_body(filename)))

    {
      result_code: response.css('epp response result').first[:code],
      msg: response.css('epp response result msg').text
    }
  end

end

RSpec.configure do |c|
  c.include Epp, epp: true
end
