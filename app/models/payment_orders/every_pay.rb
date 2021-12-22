module PaymentOrders
  class EveryPay < PaymentOrder
    include HttpRequester

    USER       = ENV['payments_every_pay_api_user']
    KEY        = ENV['payments_every_pay_api_key']
    ACCOUNT_ID = ENV['payments_every_pay_seller_account']
    LINKPAY_CHECK_PREFIX = ENV['payments_every_pay_linkpay_check_prefix']

    TRUSTED_DATA = 'trusted_data'.freeze
    SUCCESSFUL_PAYMENT = %w[settled authorized].freeze

    CONFIG_NAMESPACE = 'every_pay'.freeze

    def self.config_namespace_name
      CONFIG_NAMESPACE
    end

    def form_fields
      base_json = base_params
      base_json[:nonce] = SecureRandom.hex(15)
      hmac_fields = (base_json.keys + ['hmac_fields']).sort.uniq!

      base_json[:hmac_fields] = hmac_fields.join(',')
      hmac_string = hmac_fields.map { |key, _v| "#{key}=#{base_json[key]}" }.join('&')
      hmac = OpenSSL::HMAC.hexdigest('sha1', KEY, hmac_string)
      base_json[:hmac] = hmac

      base_json
    end

    def valid_response_from_intermediary?
      return false unless response

      valid_amount? && valid_account?
    end

    def settled_payment?
      SUCCESSFUL_PAYMENT.include?(response['payment_state'])
    end

    def payment_received?
      valid_response_from_intermediary? && settled_payment?
    end

    def composed_transaction
      base_transaction(sum: response['standing_amount'],
                       paid_at: Date.strptime(response['timestamp'], '%s'),
                       buyer_name: response['cc_holder_name'])
    end

    def create_failure_report
      notes = "User failed to make valid payment. Payment state: #{response['payment_state']}"
      status = 'cancelled'
      update!(notes: notes, status: status)
    end

    def check_linkpay_status
      return if paid?

      url = "#{LINKPAY_CHECK_PREFIX}#{response['payment_reference']}?api_username=#{USER}"
      body = basic_auth_get(url: url, username: USER, password: KEY)
      return unless body

      self.response = body.merge(type: TRUSTED_DATA, timestamp: Time.zone.now)
      save
      complete_transaction if body['payment_state'] == 'settled'
    end

    private

    def base_params
      {
        api_username: USER,
        account_id: ACCOUNT_ID,
        timestamp: Time.now.to_i.to_s,
        callback_url: response_url,
        customer_url: return_url,
        amount: number_with_precision(invoice.total, precision: 2),
        order_reference: SecureRandom.hex(15),
        transaction_type: 'charge',
        hmac_fields: ''
      }.with_indifferent_access
    end

    def valid_amount?
      return false unless response.key? 'standing_amount'

      invoice.total == response['standing_amount'].to_d
    end

    def valid_account?
      response['account_name'] == ACCOUNT_ID
    end
  end
end
