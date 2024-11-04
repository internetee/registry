module EisBilling
  class OneoffService < EisBilling::Base

    attr_reader :invoice_number, :customer_url, :amount

    def initialize(invoice_number:, customer_url:, amount: nil)
      @invoice_number = invoice_number
      @customer_url = customer_url
      @amount = amount
    end

    def self.call(invoice_number:, customer_url:, amount: nil)
      new(invoice_number: invoice_number, customer_url: customer_url, amount: amount).call
    end

    def call
      send_request
    end

    private

    def send_request
      http = EisBilling::Base.base_request
      http.post(invoice_oneoff_url, params.to_json, EisBilling::Base.headers)
    end

    def params
      {
        invoice_number: invoice_number,
        customer_url: customer_url,
        amount: amount
      }
    end

    def invoice_oneoff_url
      '/api/v1/invoice_generator/oneoff'
    end
  end
end
