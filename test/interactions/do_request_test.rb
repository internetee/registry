require 'test_helper'

class DoRequestTest < ActiveSupport::TestCase

  setup do
    WebMock.disable_net_connect!

    @uri = URI.parse("#{ENV['repp_url']}registrar/nameservers")
    @request = Net::HTTP::Put.new(@uri, 'Content-Type' => 'application/json')
    @nameserver = nameservers(:shop_ns1)
    @domain = domains(:shop)
    @user = users(:api_bestnames)

    @request.body = { data: { type: 'nameserver', id: @nameserver.hostname,
                             domains: ["shop.test"],
                             attributes: { hostname: 'new-ns.bestnames.test',
                                           ipv4: '192.0.2.55',
                                           ipv6: '2001:db8::55' } } }.to_json
    @request.basic_auth(@user.username, @user.plain_text_password)
  end

  def test_request_occurs 
    stub_request(:put, "http://epp:3000/repp/v1/registrar/nameservers").
    with(
      body: "{\"data\":{\"type\":\"nameserver\",\"id\":\"ns1.bestnames.test\",\"domains\":[\"shop.test\"],\"attributes\":{\"hostname\":\"new-ns.bestnames.test\",\"ipv4\":\"192.0.2.55\",\"ipv6\":\"2001:db8::55\"}}}",
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic dGVzdF9iZXN0bmFtZXM6dGVzdHRlc3Q=',
      'Content-Type'=>'application/json',
      'Host'=>'epp:3000',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: ["shop.test"], headers: {})

    action = Actions::DoRequest.new(@request, @uri)
    response = action.call

    assert_equal response.body, ["shop.test"]
    assert_equal response.code, "200"
  end
end