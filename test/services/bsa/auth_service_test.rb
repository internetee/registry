require 'test_helper'

class Bsa::AuthServiceTest < ActiveSupport::TestCase

  def test_for_succesfull_authentication
    service_instance = Bsa::AuthService.new(redis_required: false)
    service_instance.redis.del('bsa_token')

    token = generate_test_bsa_token(Time.zone.now + 10.minute)
    stub_succesfull_request(token)

    r = service_instance.call
    
    assert r.result?
    assert_equal r.body.id_token, token

    stored_token = service_instance.redis.get('bsa_token')
    assert_nil stored_token
  end

  def test_for_failed_authentication
    stub_failed_request

    r = Bsa::AuthService.call(redis_required: false)

    refute r.result?
    assert_equal r.error.message, 'NOT_FOUND'
    assert_equal r.error.description, 'User not found'
  end

  def test_token_should_be_put_in_redis_if_redis_available
    service_instance = Bsa::AuthService.new(redis_required: true)
    service_instance.redis.del('bsa_token')

    token = generate_test_bsa_token(Time.zone.now + 10.minute)
    stub_succesfull_request(token)

    r = service_instance.call
    
    assert r.result?
    assert_equal r.body.id_token, token

    
    stored_token = service_instance.redis.get('bsa_token')

    assert_equal token, stored_token
  end

  def test_token_shoule_be_get_from_redis_if_redis_available
    # To verify that the data is coming from redis, I will not mock a web query
    token = generate_test_bsa_token(Time.zone.now + 10.minute)

    service_instance = Bsa::AuthService.new(redis_required: true)
    service_instance.redis.set('bsa_token', token)

    r = service_instance.call

    assert r.result?
    assert_equal r.body.id_token, token
  end

  def test_token_should_be_required_if_token_is_expired
    token = generate_test_bsa_token(Time.zone.now - 20.minute)

    service_instance = Bsa::AuthService.new(redis_required: true)
    service_instance.redis.set('bsa_token', token)

    token = generate_test_bsa_token(Time.zone.now + 20.minute)
    stub_succesfull_request(token)

    r = service_instance.call

    assert r.result?
    assert_equal r.body.id_token, token
  end

  private

  def stub_succesfull_request(token)
    stub_request(:post, "https://api-ote.bsagateway.co/iam/api/authenticate/apiKey")
      .to_return(
        status: 200,
        body: { id_token: token }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_failed_request
    stub_request(:post, "https://api-ote.bsagateway.co/iam/api/authenticate/apiKey")
      .to_return(
        status: 401,
        body: { message: 'NOT_FOUND', description: "User not found" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
