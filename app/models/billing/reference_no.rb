module Billing
  class ReferenceNo
    REGEXP = /\A\d{2,20}\z/.freeze

    def self.generate
      base = Base.generate
      "#{base}#{base.check_digit}"
    end
  end
end
