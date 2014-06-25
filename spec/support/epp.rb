module Epp
  def read_body filename
    File.read("spec/epp/requests/#{filename}")
  end

  def parse_result_code response
    response.css('epp response result').first[:code]
  end
end

RSpec.configure do |c|
  c.include Epp, epp: true
end
