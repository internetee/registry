require 'test_helper'

class EveryPayTest < ActiveSupport::TestCase
  def setup
    super

    @original_methods = ENV['payment_methods']
    @original_seb_URL = ENV['seb_payment_url']
    ENV['payment_methods'] = 'seb, swed, credit_card'
    ENV['seb_payment_url'] = 'https://example.com/seb_url'
    ENV['seb_seller_account'] = 'SEB'
    ENV['seb_bank_certificate'] = 'test/fixtures/files/seb_bank_cert.pem'
    ENV['seb_seller_certificate'] = 'test/fixtures/files/seb_seller_key.pem'

    @invoice = invoices(:valid)
    params = {
      response:
        {
          utf8:"✓",
          _method: "put",
          authenticity_token: "OnA69vbccQtMt3C9wxEWigs5Gpf/7z+NoxRCMkFPlTvaATs8+OgMKF1I4B2f+vuK37zCgpWZaWWtyuslRRSwkw==",
          nonce: "8a9063b3c13edb00522d446481cb1886",
          timestamp: "1524036436",
          api_username: "ca8d6336dd750ddb",
          transaction_result: "completed",
          payment_reference: "3380fc36f02a7c1d2b0a700794e7a6ef8683191b3f0dc88b762e72c6e573adaf",
          payment_state: "settled",
          amount: "240.0",
          order_reference: "59fa7f639211d1e14952bad73ccb50",
          account_id: "EUR3D1",
          cc_type: "master_card",
          cc_last_four_digits: "0487",
          cc_month: "10",
          cc_year: "2018",
          cc_holder_name: "John Doe",
          hmac_fields: "account_id,amount,api_username,cc_holder_name,cc_last_four_digits,cc_month,cc_type,cc_year,hmac_fields,nonce,order_reference,payment_reference,payment_state,timestamp,transaction_result",
          hmac: "d5b11b001b248532ad5af529f072b5b76347936a",
          controller: "registrar/payments",
          action: "back",
          bank: "every_pay"
        },
    }
    @every_pay = Payments::EveryPay.new('every_pay', @invoice, params)

    travel_to '2018-04-01 00:30'
  end

  def teardown
    super

    ENV['payment_methods'] = @original_methods
    ENV['seb_payment_url'] = @original_seb_URL
    travel_back
  end

  def test_form_fields
  end

  def test_is_not_valid_without_response
  end

  def test_validation
  end
end
