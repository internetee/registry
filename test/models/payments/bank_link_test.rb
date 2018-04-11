require 'test_helper'

class BankLinkTest < ActiveSupport::TestCase
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
    params = {return_url: 'return.url', response_url: 'response_url'}
    @bank_link = Payments::BankLink.new('seb', @invoice, params)

    travel_to '2018-04-01 00:30'
  end

  def teardown
    super

    ENV['payment_methods'] = @original_methods
    ENV['seb_payment_url'] = @original_seb_URL
    travel_back
  end

  def test_form_fields
    expected_response = {
      "VK_SERVICE": "1012",
      "VK_VERSION": "008",
      "VK_SND_ID": "SEB",
      "VK_STAMP": nil,
      "VK_AMOUNT": nil,
      "VK_CURR": "EUR",
      "VK_REF": "",
      "VK_MSG": "Order nr. ",
      "VK_RETURN": "return.url",
      "VK_CANCEL": "return.url",
      "VK_DATETIME": "2018-04-01T00:30:00+0300",
      "VK_MAC": "fPHKfBNwtyQI5ec1pnrlIUJI6nerGPwnoqx0K9/g40hsgUmum4QE1Eq992FR73pRXyE2+1dUuahEd3s57asM7MOD2Pb8SALA/+hi3jlqjiAAThdikDuJ+83LogSKQljLdd0BHwqe+O0WPeKaOmP2/HltOEIHpY3d399JAi1t7YA=",
      "VK_ENCODING": "UTF-8",
      "VK_LANG": "ENG"
    }.with_indifferent_access

    assert_equal expected_response, @bank_link.form_fields
  end

  def test_is_not_valid_without_response
    assert_equal false, @bank_link.valid_response?
  end
end
