require 'test_helper'

class BankLinkTest < ActiveSupport::TestCase
  def setup
    super
    @invoice = invoices(:valid)
    params = {return_url: 'return.url', response_url: 'response.url'}
    @bank_link = Payments::BankLink.new('seb', @invoice, params)

    travel_to '2018-04-01 00:30'
  end

  def teardown
    super
    travel_back
  end

  def test_is_not_valid_without_response
    assert_equal false, @bank_link.valid_response?
  end
end
