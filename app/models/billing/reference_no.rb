module Billing
  class ReferenceNo
    REGEXP = /\A\d{2,20}\z/
    MULTI_REGEXP = /(\d{2,20})/

    def self.generate
      result = EisBilling::GetReferenceNumber.send_request
      JSON.parse(result.body)['reference_number']
    end

    def self.valid?(ref)
      base = Base.new(ref.to_s[0...-1])
      ref.to_s == "#{base}#{base.check_digit}"
    end
  end
end
