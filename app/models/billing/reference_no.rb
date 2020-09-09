module Billing
  class ReferenceNo
    REGEXP = /\A\d{2,20}\z/
    MULTI_REGEXP = /(\d{2,20})/

    def self.generate
      base = Base.generate
      "#{base}#{base.check_digit}"
    end
  end
end
