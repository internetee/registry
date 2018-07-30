require 'test_helper'

class RegistrantApiAuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    super

    @user_hash = {ident: '37010100049', first_name: 'Adam', last_name: 'Baker'}
    @existing_user = RegistrantUser.find_or_create_by_api_data(@user_hash)
  end

  def teardown
    super

  end

  def test_request_creates_user_when_one_does_not_exist
    params = {
      ident: '30110100103',
      first_name: 'John',
      last_name: 'Smith',
    }

    post '/api/v1/registrant/auth/eid', params
    assert(User.find_by(registrant_ident: 'EE-30110100103'))

    json = JSON.parse(response.body, symbolize_names: true)
    assert_equal([:access_token, :expires_at, :type], json.keys)
  end

  def test_request_returns_existing_user
    assert_no_changes User.count do
      post '/api/v1/registrant/auth/eid', @user_hash
    end
  end

  def test_request_returns_401_from_a_not_whitelisted_ip
    params = { foo: :bar, test: :test }
    @original_whitelist_ip = ENV['registrant_api_auth_allowed_ips']
    ENV['registrant_api_auth_allowed_ips'] = '1.2.3.4'

    post '/api/v1/registrant/auth/eid', params
    assert_equal(401, response.status)
    json_body = JSON.parse(response.body, symbolize_names: true)

    assert_equal({error: 'Not authorized'}, json_body)

    ENV['registrant_api_auth_allowed_ips'] = @original_whitelist_ip
  end

  def test_request_documented_parameters_are_required
    params = { foo: :bar, test: :test }

    post '/api/v1/registrant/auth/eid', params
    json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({errors: [{ident: ['parameter is required']}]}, json)
    assert_equal(422, response.status)
  end
end
