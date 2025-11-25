require 'test_helper'

class ReppV1AccreditationResultsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @accr_bot = users(:accr_bot)
    ENV['allow_accr_endspoints'] = 'true'
  end

  def teardown
    ENV.delete('allow_accr_endspoints')
    super
  end

  def test_should_only_allow_accr_bot_to_push_results
    post '/repp/v1/registrar/accreditation/push_results',
         headers: auth_headers(@user),
         params: { accreditation_result: { username: @user.username, result: true } }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal json[:code], 2202
    assert_equal json[:message], 'Only accr_bot can update accreditation results'
  end

  def test_should_return_valid_response
    post '/repp/v1/registrar/accreditation/push_results',
         headers: auth_headers(@accr_bot),
         params: { accreditation_result: { username: @user.username, result: true } }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_emails 2
    assert_equal json[:data][:result], 'true'
  end

  def test_should_return_valid_response_invalid_authorization
    post '/repp/v1/registrar/accreditation/push_results',
         headers: { 'Authorization' => 'Basic temporary-secret-ke' },
         params: { accreditation_result: { username: @user.username, result: true } }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized

    assert_emails 0
    assert_equal json[:code], 2202
    assert_equal json[:message], 'Invalid authorization information'
  end

  def test_should_return_valid_response_record_exception
    post '/repp/v1/registrar/accreditation/push_results',
         headers: auth_headers(@accr_bot),
         params: { accreditation_result: { username: 'chungachanga', result: true } }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found

    assert_emails 0
    assert_equal json[:code], 2303
    assert_equal json[:message], 'Object does not exist'
  end

  private

  def generate_token(user)
    Base64.encode64("#{user.username}:#{user.plain_text_password}")
  end

  def auth_headers(user)
    { 'Authorization' => "Basic #{generate_token(user)}" }
  end
end
