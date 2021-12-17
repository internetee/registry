# frozen_string_literal: true

module Invoice::Linkpayable
  extend ActiveSupport::Concern

  KEY = ENV['payments_every_pay_api_key']
  LINKPAY_PREFIX = ENV['payments_every_pay_linkpay_prefix']
  LINKPAY_CHECK_PREFIX = ENV['payments_every_pay_linkpay_check_prefix']
  LINKPAY_TOKEN = ENV['payments_every_pay_linkpay_token']
  LINKPAY_QR = ENV['payments_every_pay_linkpay_qr']

  def linkpay_url
    return if paid?

    linkpay_url_builder
  end

  def linkpay_url_builder
    price = Money.from_amount(total, 'EUR')
    data = CGI.unescape(linkpay_params(price).to_query)

    hmac = OpenSSL::HMAC.hexdigest('sha256', KEY, data)
    "#{LINKPAY_PREFIX}?#{CGI.unescape(data)}&hmac=#{hmac}"
  end

  def linkpay_params(price)
    { 'transaction_amount' => price.to_s,
      'order_reference' => number,
      'customer_name' => buyer_name.parameterize(separator: '_', preserve_case: true),
      'customer_email' => buyer.email,
      'custom_field_1' => description.parameterize(separator: '_', preserve_case: true),
      'linkpay_token' => LINKPAY_TOKEN,
      'invoice_number' => number }
  end

  def qr_enabled?
    !!LINKPAY_QR
  end
end
