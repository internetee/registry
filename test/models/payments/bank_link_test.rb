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

  def test_is_not_valid_without_response
    assert_equal false, @bank_link.valid_response?
  end
end
