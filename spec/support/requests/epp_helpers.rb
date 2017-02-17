module Requests
  module EPPHelpers
    def have_code_of(*args)
      Matchers::EPP::Code.new(*args)
    end
  end
end
