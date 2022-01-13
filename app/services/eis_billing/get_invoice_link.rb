module EisBilling
  class GetInvoiceLink < EisBilling::Base
    attr_reader :invoice_number

    def initialize(invoice_number)
      @invoice_number = invoice_number
    end

    def send_request
      base_request
    end

    private

    def base_request
      uri = URI(invoice_generator_url)
      http = Net::HTTP.new(uri.host, uri.port)
      headers = {
        'Authorization'=>'Bearer foobar',
        'Content-Type' =>'application/json',
        'Accept'=> TOKEN
      }

      res = http.get(invoice_generator_url + "?invoice_number=#{@invoice_number}", headers)
      res
    end

    def invoice_generator_url
      "#{BASE_URL}/api/v1/get_invoice_payment_link/show"
    end
  end
end
