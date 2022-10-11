class SyncAccreditedUsersJob < ApplicationJob
  def perform
    uri = URI.parse(ENV['registry_demo_accredited_users_url'])
    response = base_get_request(uri: uri)

    if response.code == '200'
      result = JSON.parse(response.body)
      result['users'].each do |api|
        a = ApiUser.find_by(username: api.username, identity_code: api.identity_code)
        Actions::RecordDateOfTest.record_result_to_api_user(a, api.accreditation_date) unless a.nil?
      end
    else
      logger.warn 'User not found'
    end

    nil
  end

  private

  def base_get_request(uri:)
    http = Net::HTTP.new(uri.host)
    http.use_ssl = true unless Rails.env.development?
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

    req = Net::HTTP::Get.new(uri.request_uri, headers)

    http.request(req)
  end

  def generate_token
    JWT.encode(payload, accr_secret)
  end

  def payload
    {
      secret: 'accr'
    }
  end

  def headers
    {
      'Authorization' => "Bearer #{generate_token}",
      'Content-Type' => 'application/json',
    }
  end

  def accr_secret
    ENV['accreditation_secret']
  end
end
