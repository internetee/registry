require 'test_helper'

class ReppV1CertificatesCreateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_creates_new_api_user_certificate_and_informs_admins
    # Отладка - декодируем CSR и проверяем CN
    csr_base64 = request_body[:certificate][:csr][:body]
    csr_decoded = Base64.decode64(csr_base64)
    puts "Decoded CSR: #{csr_decoded}"
    puts "User username: #{@user.username}"
    
    assert_difference('Certificate.count') do
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do
        post repp_v1_certificates_path, headers: @auth_headers, params: request_body
        
        # Добавляем отладочный вывод
        if response.status != 200
          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
        end
      end
    end
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
  end

  def test_return_error_when_invalid_certificate
    request_body = {
      certificate: {
        api_user_id: @user.id,
        csr: {
          body: 'invalid',
          type: 'csr',
        },
      },
    }

    post repp_v1_certificates_path, headers: @auth_headers, params: request_body
    
    # Отладочный вывод
    puts "Response status: #{response.status}"
    puts "Response body: #{response.body}"
    
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert json[:message].include? I18n.t(:crt_or_csr_must_be_present)
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    post repp_v1_certificates_path, headers: @auth_headers, params: request_body
    post repp_v1_certificates_path, headers: @auth_headers, params: request_body
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end

  def request_body
    {
      certificate: {
        api_user_id: @user.id,
        csr: {
          body: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ3dqQ0NB\n" \
            "YW9DQVFBd2ZURUxNQWtHQTFVRUJoTUNSVlF4RVRBUEJnTlZCQWdNQ0VoaGNt\n" \
            "cDFiV0ZoTVJBdwpEZ1lEVlFRSERBZFVZV3hzYVc1dU1SUXdFZ1lEVlFRS0RB\n" \
            "dEpiblJsY201bGRDNWxaVEVRTUE0R0ExVUVBd3dICmFHOXpkQzVsWlRFaE1C\n" \
            "OEdDU3FHU0liM0RRRUpBUllTYzJWeVoyVnBkRFpBWjIxaGFXd3VZMjl0TUlJ\n" \
            "QklqQU4KQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBdk80\n" \
            "UWltNlFxUzFRWVVRNjFUbGk0UG9DTTlhZgp4dUI5ZFM4endMb2hsOWhSOWdI\n" \
            "dGJmcHpwSk5hLzlGeW0zcUdUZ3V0eVd3VGtWV3FzL0o3UjVpckxaY1pKaXI4\n" \
            "CnZMZEo4SWlKL3ZTRDdNeS9oNzRRdHFGZlNNSi85bzAyUkJRdVFSWUU4Z3hU\n" \
            "ZTRiMjU5NUJVQnZIUTFyczQxaGoKLzJ6SytuRDBsbHVvUFdrNnBCZ1NGZkN1\n" \
            "Y0tWcE44Tm5vZUdGUjRnWHJQT0t2bkMwb3BxNi9SWmJxYm9hbTkxZwpWYWJ0\n" \
            "Y0t4d3pmd2kxUlYzUUVxRXRUY0QvS0NwTzJRMTVXR3FtN2ZFYVMwVlZCckZw\n" \
            "bzZWanZCSXUxRXJvcWJZCnBRaE9MZSt2RUh2bXFTS2JhZmFGTC9ZNHZyaU9P\n" \
            "aU5yS01LTnR3cmVzeUI5TVh4YlNlMG9LSE1IVndJREFRQUIKb0FBd0RRWUpL\n" \
            "b1pJaHZjTkFRRUxCUUFEZ2dFQkFKdEViWnlXdXNaeis4amVLeVJzL1FkdXNN\n" \
            "bEVuV0RQTUdhawp3cllBbTVHbExQSEEybU9TUjkwQTY5TFBtY1FUVUtTTVRa\n" \
            "NDBESjlnS2IwcVM3czU2UVFzblVQZ0hPMlFpWDlFCjZRcnVSTzNJN2kwSHZO\n" \
            "K3g1Q29qUHBwQTNHaVdBb0dObG5uaWF5ZTB1UEhwVXFLbUcwdWFmVUpXS2tL\n" \
            "Vi9vN3cKQXBIQWlQU0lLNHFZZ1FtZDBOTTFmM0FBL21pRi9xa3lZVGMya05s\n" \
            "bG5DNm9vdldmV2hvSjdUdWluaE9Ka3BaaAp6YksxTHVoQ0FtWkNCVHowQmRt\n" \
            "R2szUmVKL2dGTGpHWC9qd3BQRURPRGJHdkpYSzFuZzBwbXFlOFZzSms2SVYz\n" \
            "Ckw0T3owY1JzTTc1UGtQbGloQ3RJOEJGQk04YVhCZjJ6QXZiV0NpY3piWTRh\n" \
            "enBzc3VMbz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==\n",
          type: 'csr',
        },
      },
    }
  end
end
