module EisBilling
  class AddDeposits < EisBilling::Base
    attr_reader :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def send_invoice
      base_request(json_obj: parse_invoice)
    end

    private

    def parse_invoice
      data = {}
      data[:transaction_amount] = invoice.total.to_s
      data[:order_reference] = invoice.number
      data[:customer_name] = invoice.buyer_name
      data[:customer_email] = invoice.buyer_email
      data[:custom_field_1] = invoice.description
      data[:custom_field_2] = 'registry'
      data[:invoice_number] = invoice.number

      data

      # invoice = @invoice.to_json(except: [ :order_reference,
      #                                      :created_at,
      #                                      :updated_at,
      #                                      :e_invoice_sent_at,
      #                                      :items_attributes])

      # parsed_data = JSON.parse(invoice)
      # parsed_data['role'] = 'registrar'
      # parsed_data['source'] = 'registry'
      # parsed_data['description'] = 'some' if parsed_data['description'] == ''

      # parsed_data = replace_key(json_obj: parsed_data, old_key: 'total', new_key: 'transaction_amount')
      # parsed_data = replace_key(json_obj: parsed_data, old_key: 'reference_no', new_key: 'reference_number')

      # invoice_items_json = @invoice.items.to_json(except: [ :created_at, :updated_at ])
      # parsed_data['items'] = JSON.parse(invoice_items_json)
      # parsed_data
    end

    # def replace_key(json_obj:, old_key:, new_key:)
    #   json_obj[new_key] = json_obj[old_key]
    #   json_obj.delete(old_key)

    #   json_obj
    # end

    def base_request(json_obj:)
      uri = URI(invoice_generator_url)
      http = Net::HTTP.new(uri.host, uri.port)
      headers = {
        'Authorization' => 'Bearer foobar',
        'Content-Type' => 'application/json',
        'Accept' => TOKEN
      }

      res = http.post(invoice_generator_url, json_obj.to_json, headers)
      res
    end

    def invoice_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/invoice_generator"
    end
  end
end
