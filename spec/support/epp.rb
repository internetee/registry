module Epp
  def read_body(filename)
    File.read("spec/epp/requests/#{filename}")
  end
end

RSpec.configure do |c|
  c.include Epp, type: :epp
end
