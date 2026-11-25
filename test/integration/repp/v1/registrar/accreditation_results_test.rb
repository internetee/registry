require 'test_helper'

class ReppV1AccreditationResultsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @accr_bot = users(:accr_bot)
  end

  def test_should_only_allow_accr_bot_to_push_results
    post '/repp/v1/registrar/accreditation/push_results',
         headers: auth_headers(@user),
         params: { accreditation_result: { registrar_name: @user.registrar.name } }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized
    assert_equal json[:code], 2202
    assert_equal json[:message], 'Only accr_bot can update accreditation results'
  end

  def test_should_return_valid_response
    last_theory_test_passed_at = Time.zone.parse('2026-01-15 10:00:00')

    post '/repp/v1/registrar/accreditation/push_results',
         headers: auth_headers(@accr_bot),
         params: {
           accreditation_result: {
             registrar_name: @user.registrar.name,
             last_theory_test_passed_at: last_theory_test_passed_at.iso8601
           }
         }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_emails 0
    assert_equal json[:data][:registrar_name], @user.registrar.name
    assert_equal json[:data][:accreditation_date].to_date, last_theory_test_passed_at.to_date
    assert_equal json[:data][:accreditation_expire_date].to_date,
                 (last_theory_test_passed_at + ENV.fetch('accr_expiry_months', 24).to_i.months).to_date
  end

  def test_should_return_valid_response_invalid_authorization
    post '/repp/v1/registrar/accreditation/push_results',
         headers: { 'Authorization' => 'Basic temporary-secret-ke' },
         params: { accreditation_result: { registrar_name: @user.registrar.name } }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unauthorized

    assert_emails 0
    assert_equal json[:code], 2202
    assert_equal json[:message], 'Invalid authorization information'
  end

  def test_should_return_valid_response_record_exception
    post '/repp/v1/registrar/accreditation/push_results',
         headers: auth_headers(@accr_bot),
         params: { accreditation_result: { registrar_name: 'chungachanga' } }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :unprocessable_entity

    assert_emails 0
    assert_equal json[:code], 2304
    assert json[:message].present?
  end

  private

  def generate_token(user)
    Base64.encode64("#{user.username}:#{user.plain_text_password}")
  end

  def auth_headers(user)
    { 'Authorization' => "Basic #{generate_token(user)}" }
  end
end
