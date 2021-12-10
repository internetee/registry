class SyncAccreditedUsersJob < ApplicationJob
  def perform
  #   apiusers_from_test = Actions::GetAccrResultsFromAnotherDb.list_of_accredated_users

  #   return if apiusers_from_test.nil?

  #   apiusers_from_test.each do |api|
  #     a = ApiUser.find_by(username: api.username, identity_code: api.identity_code)
  #     Actions::RecordDateOfTest.record_result_to_api_user(a, api.accreditation_date) unless a.nil?
  #   end
    uri = URI.parse(ENV['registry_demo_accredited_users_url'])

    response = base_get_request(uri: uri, port: ENV['registry_demo_registrar_port'])

    if response.code == "200"
      result = JSON.parse(response.body)
      users = result['users']

      users.each do |api|
        a = ApiUser.find_by(username: api.username, identity_code: api.identity_code)
        Actions::RecordDateOfTest.record_result_to_api_user(a, api.accreditation_date) unless a.nil?
      end
    else
      logger.warn 'User not found'
    end

    return
  end

  private

  def base_get_request(uri:, port:)
    http = Net::HTTP.new(uri.host, port)
    req = Net::HTTP::Get.new(uri.request_uri)

    http.request(req)
  end
end