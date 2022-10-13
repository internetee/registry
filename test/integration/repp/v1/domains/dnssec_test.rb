require 'test_helper'

class ReppV1DomainsDnssecTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_shows_dnssec_keys_associated_with_domain
    get "/repp/v1/domains/#{@domain.name}/dnssec", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_empty json[:data][:dns_keys]

    payload = {
      dns_keys: [
        { flags: '256',
          alg: '14',
          protocol: '3',
          public_key: 'dGVzdA==' },
      ],
    }

    post "/repp/v1/domains/#{@domain.name}/dnssec", params: payload, headers: @auth_headers

    get "/repp/v1/domains/#{@domain.name}/dnssec", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_equal 1, json[:data][:dns_keys].length
  end

  def test_creates_dnssec_key_successfully
    assert @domain.dnskeys.empty?
    payload = {
      dns_keys: [
        { flags: '256',
          alg: '14',
          protocol: '3',
          public_key: 'dGVzdA==' },
      ],
    }

    post "/repp/v1/domains/#{@domain.name}/dnssec", params: payload, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)
    @domain.reload

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert @domain.dnskeys.present?
    dnssec_key = @domain.dnskeys.last
    assert_equal payload[:dns_keys][0][:flags].to_i, dnssec_key.flags
    assert_equal payload[:dns_keys][0][:alg].to_i, dnssec_key.alg
    assert_equal payload[:dns_keys][0][:protocol].to_i, dnssec_key.protocol
    assert_equal payload[:dns_keys][0][:public_key], dnssec_key.public_key
  end

  def test_creates_dnssec_key_with_every_algo
    algos = Dnskey::ALGORITHMS
    algos_to_check = %w[15 16]

    assert (algos & algos_to_check) == algos_to_check

    algos.each do |alg|
      assert @domain.dnskeys.empty?
      payload = {
        dns_keys: [
          { flags: '256',
            alg: alg,
            protocol: '3',
            public_key: 'dGVzdA==' },
        ],
      }

      post "/repp/v1/domains/#{@domain.name}/dnssec", params: payload, headers: @auth_headers
      json = JSON.parse(response.body, symbolize_names: true)
      @domain.reload

      assert_response :ok
      assert_equal 1000, json[:code]
      assert_equal 'Command completed successfully', json[:message]

      assert @domain.dnskeys.present?
      dnssec_key = @domain.dnskeys.last
      assert_equal payload[:dns_keys][0][:alg].to_i, dnssec_key.alg
      @domain.dnskeys.destroy_all
    end
  end

  def test_removes_existing_dnssec_key_successfully
    payload = {
      dns_keys: [
        { flags: '256',
          alg: '14',
          protocol: '3',
          public_key: 'dGVzdA==' },
      ],
    }

    post "/repp/v1/domains/#{@domain.name}/dnssec", params: payload, headers: @auth_headers

    assert @domain.dnskeys.any?

    # Real delete here
    delete "/repp/v1/domains/#{@domain.name}/dnssec", params: payload, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)
    @domain.reload

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert @domain.dnskeys.empty?
  end
end
