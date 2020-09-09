module Billing
  class ReferenceNo
    REGEXP = /\A\d{2,20}\z/.freeze
    MULTI_REGEXP = /(\d{2,20})/.freeze

    def self.generate
      base = Base.generate
      "#{base}#{base.check_digit}"
    end
  end
end
