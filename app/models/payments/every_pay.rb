module Payments
  class EveryPay < Base

    # TODO: Move to setting or environment
    USER       = ENV['payments_every_pay_api_user'].freeze
    KEY        = ENV['payments_every_pay_api_key'].freeze
    ACCOUNT_ID = ENV['payments_every_pay_seller_account'].freeze
    SUCCESSFUL_PAYMENT = %w(settled authorized).freeze

    def form_fields
      base_json = base_params
      base_json[:nonce] = SecureRandom.hex(15)
      hmac_fields = (base_json.keys + ['hmac_fields']).sort.uniq!

      # Not all requests require use of hmac_fields, add only when needed
      base_json[:hmac_fields] = hmac_fields.join(',')
      hmac_string = hmac_fields.map { |k, _v| "#{k}=#{base_json[k]}" }.join('&')
      hmac = OpenSSL::HMAC.hexdigest('sha1', KEY, hmac_string)
      base_json[:hmac] = hmac

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
      return unless valid_response? && settled_payment?

      transaction = BankTransaction.find_by(
        description: invoice.order,
        currency:    invoice.currency,
        iban:        invoice.seller_iban
      )

      transaction.sum = response[:amount]
      transaction.paid_at = DateTime.strptime(response[:timestamp], '%s')
      transaction.buyer_name = response[:cc_holder_name]
      transaction.save!

      transaction.autobind_invoice
    end

    private

    def base_params
      {
        api_username: USER,
        account_id: ACCOUNT_ID,
        timestamp: Time.now.to_i.to_s,
        callback_url: response_url,
        customer_url: return_url,
        amount: invoice.total,
        order_reference: SecureRandom.hex(15),
        transaction_type: 'charge',
        hmac_fields: ''
      }.with_indifferent_access
    end

    def valid_hmac?
      hmac_fields = response[:hmac_fields].split(',')
      hmac_hash = {}
      hmac_fields.map do |field|
        hmac_hash[field.to_sym] = response[field.to_sym]
      end

      hmac_string = hmac_hash.map { |k, _v| "#{k}=#{hmac_hash[k]}" }.join('&')
      expected_hmac = OpenSSL::HMAC.hexdigest('sha1', KEY, hmac_string)
      expected_hmac == response[:hmac]
    end

    def valid_amount?
      invoice.total == BigDecimal.new(response[:amount])
    end

    def valid_account?
      response[:account_id] == ACCOUNT_ID
    end
  end
end
