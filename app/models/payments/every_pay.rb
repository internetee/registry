module Payments
  class EveryPay < Base

    # TODO: Move to setting or environment
    USER       = ENV['every_pay_api_user'].freeze
    KEY        = ENV['every_pay_api_key'].freeze
    ACCOUNT_ID = ENV['every_pay_seller_account'].freeze
    SUCCESSFUL_PAYMENT = %w(settled authorized).freeze

    def form_fields
      base_json = base_params
      base_json.merge!("nonce": SecureRandom.hex(15))
      hmac_fields = (base_json.keys + ["hmac_fields"]).sort.uniq!

      # Not all requests require use of hmac_fields, add only when needed
      base_json["hmac_fields"] = hmac_fields.join(",")
      hmac_string = hmac_fields.map{|k, _v| "#{k}=#{base_json[k]}"}.join("&")
      hmac = OpenSSL::HMAC.hexdigest("sha1", KEY, hmac_string)
      base_json.merge!("hmac": hmac)

      base_json
    end

    def valid_response?
      return false unless response
      valid_hmac? && valid_amount? && valid_account?
    end

    def settled_payment?
      SUCCESSFUL_PAYMENT.include?(response[:payment_state])
    end

    def complete_transaction
      if valid_response? && settled_payment?
        transaction = BankTransaction.find_by(
          reference_no: invoice.reference_no,
          currency:     invoice.currency,
          iban:         invoice.seller_iban
        )

        transaction.sum = response[:amount]
        transaction.paid_at = DateTime.strptime(response[:timestamp],'%s')
        transaction.buyer_name = response[:cc_holder_name]
        transaction.save!

        transaction.autobind_invoice
      end
    end

    private

    def base_params
      {
	      api_username: USER,
		    account_id: ACCOUNT_ID,
		    timestamp: Time.now.to_i.to_s,
		    callback_url: response_url,
		    customer_url: return_url,
		    amount: invoice.sum_cache,
		    order_reference: SecureRandom.hex(15),
		    transaction_type: "charge",
        hmac_fields: ""
      }.with_indifferent_access
    end

    def valid_hmac?
      hmac_fields = response[:hmac_fields].split(',')
      hmac_hash = {}
      hmac_fields.map do|field|
        hmac_hash[field.to_sym] = response[field.to_sym]
      end

      hmac_string = hmac_hash.map {|k, _v|"#{k}=#{hmac_hash[k]}"}.join("&")
      expected_hmac = OpenSSL::HMAC.hexdigest("sha1", KEY, hmac_string)
      expected_hmac == response[:hmac]
    end

    def valid_amount?
      invoice.sum_cache == BigDecimal.new(response[:amount])
    end

    def valid_account?
      response[:account_id] == ACCOUNT_ID
    end

    def return_params
      {"utf8"=>"✓",
       "_method"=>"put",
       "authenticity_token"=>"Eb0/tFG0zSJriUUmDykI8yU/ph3S19k0KyWI2/Vxd9srF46plVJf8z8vRrkbuziMP6I/68dM3o/+QwbrI6dvSw==",
       "nonce"=>"2375e05dfd12db5af207b11742b70bda",
       "timestamp"=>"1523887506",
       "api_username"=>"ca8d6336dd750ddb",
       "transaction_result"=>"completed",
       "payment_reference"=>"95c98cd27f927e93ab7bcf7968ebff7fe4ca9314ab85b5cb15b2a6d59eb56940",
       "payment_state"=>"settled",
       "amount"=>"240.0",
       "order_reference"=>"0c430ff649e1760313e4d98b5e90e6",
       "account_id"=>"EUR3D1",
       "cc_type"=>"master_card",
       "cc_last_four_digits"=>"0487",
       "cc_month"=>"10",
       "cc_year"=>"2018",
       "cc_holder_name"=>"John Doe",
       "hmac_fields"=>"account_id,amount,api_username,cc_holder_name,cc_last_four_digits,cc_month,cc_type,cc_year,hmac_fields,nonce,order_reference,payment_reference,payment_state,timestamp,transaction_result",
       "hmac"=>"4a2ed8729be9a0c35c27fe331d01c4df5d8707c1",
       "controller"=>"registrar/payments/every_pay",
       "action"=>"update",
       "invoice_id"=>"1"}
    end
  end
end
