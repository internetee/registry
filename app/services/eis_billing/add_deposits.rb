module EisBilling
  class AddDeposits
    attr_reader :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def some_meth
      result = base_request(url: invoice_generator_url, json_obj: parse_invoice)

      p "++++++++++"
      p result
      p result.body
      p "++++++++++"
    end

    private

    def parse_invoice
      invoice = @invoice.to_json(except: [ :order_reference,
                                           :created_at,
                                           :updated_at,
                                           :e_invoice_sent_at,
                                           :issue_date,
                                           :due_date])

      parsed_data = JSON.parse(invoice)
      parsed_data["role"] = "registrar"
      parsed_data["invoice_number"] = "2232"
      parsed_data["description"] = "some" if parsed_data["description"] == ''

      parsed_data = replace_key(json_obj: parsed_data, old_key: "total", new_key: "transaction_amount")
      parsed_data = replace_key(json_obj: parsed_data, old_key: "reference_no", new_key: "reference_number")

      p parsed_data
      parsed_data
    end

    def replace_key(json_obj:, old_key:, new_key:)
      json_obj[new_key] = json_obj[old_key]
      json_obj.delete(old_key)

      json_obj
    end

    #  crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
    # irb(main):047:0> encrypted_data = crypt.encrypt_and_sign('PLEASE CREATE INVOICE')
    # => "HFW8ADSIrjyD9cbH4H5Rk3MY/ZfhV85IlnGl7YI2CQ==--OvlWMMiTLLotgdfT--/ffejEDaIGFfz7FzzNSlYA=="
    # irb(main):048:0> decrypted_back = crypt.decrypt_and_verify(encrypted_data)
    # => "PLEASE CREATE INVOICE"
    def base_request(url:, json_obj:)
      uri = URI(url)
      token = "Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw=="
      http = Net::HTTP.new(uri.host, uri.port)
      headers = {
        'Authorization'=>'Bearer foobar',
        'Content-Type' =>'application/json',
        'Accept'=> token
      }

      res = http.post("http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator", json_obj.to_json, headers)
      res
    end

    def invoice_generator_url
      "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_generator"
    end
  end
end

# http://127.0.0.1:3000/api/v1/invoice_generator/invoice_generator?description=this is description&currency=EUR&invoice_number=1233244&transaction_amount=1000&seller_name=EIS&seller_reg_no=122&seller_iban=34234234234424&seller_bank=LHV&seller_swift=1123344&seller_vat_no=23321&seller_country_code=EE&seller_state=Harjumaa&seller_street=Paldiski mnt&seller_city=Tallinn&seller_zip=23123&seller_phone=+372.342342&seller_url=eis.ee&seller_email=eis@internet.ee&seller_contact_name=Eesti Internet SA&buyer_name=Oleg&buyer_reg_no=324344&buyer_country_code=EE&buyer_state=Harjumaa&buyer_street=Kivila&buyer_city=Tallinn&buyer_zip=13919&buyer_phone=+372.59813318&buyer_url=n-brains.com&buyer_email=oleg.hasjanov@eestiinternet.ee&vat_rate=20&role=private_user&reference_number=22112233&buyer_vat_no=2332323&buyer_iban=4454322423432&invoice_items={}


# :description,
#   :currency,
#   :invoice_number,
#   :transaction_amount, => total
#   :order_reference, => no need
#   :seller_name,
#   :seller_reg_no,
#   :seller_iban,
#   :seller_bank,
#   :seller_swift,
#   :seller_vat_no,
#   :seller_country_code,
#   :seller_state,
#   :seller_street,
#   :seller_city,
#   :seller_zip,
#   :seller_phone,
#   :seller_url,
#   :seller_email,
#   :seller_contact_name,
#   :buyer_name,
#   :buyer_reg_no,
#   :buyer_country_code,
#   :buyer_state,
#   :buyer_street,
#   :buyer_city,
#   :buyer_zip,
#   :buyer_phone,
#   :buyer_url,
#   :buyer_email,
#   :vat_rate,
#   :items_attributes, => ??
#   :role, => ???
#   :buyer_iban, => ??
#   :buyer_vat_no,
#   :reference_number, => reference_no
#   :invoice_items => ?????
