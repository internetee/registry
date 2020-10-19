require 'test_helper'

class ReppV1ContactsTest < ActionDispatch::IntegrationTest
  def setup
    @auction = auctions(:one)
    @auction.update!(uuid: '1b3ee442-e8fe-4922-9492-8fcb9dccc69c',
                     domain: 'auction.test',
                     status: Auction.statuses[:started])
  end

  def test_get_index
    get repp_v1_contacts_path
    response_json = JSON.parse(response.body, symbolize_names: true)

    puts response_json

    assert response_json[:count] == 1

    expected_response = [{ domain_name: @auction.domain,
                           punycode_domain_name: @auction.domain }]

    assert_equal expected_response, response_json[:auctions]
  end
end
