module ApiLog
  class ReppLog < Db
    IDENTITY_APPROVAL_PATH = '/repp/v1/api_users/approve_verification/'.freeze

    scope :failed_identity_verifications, lambda {
      where('request_path LIKE ?', "#{IDENTITY_APPROVAL_PATH}%").where.not(response_code: '200')
    }

    def failed_identity_verification?
      request_path.to_s.start_with?(IDENTITY_APPROVAL_PATH) && response_code.to_s != '200'
    end

    # Details from the REPP response of a failed manual identity approval.
    def identity_verification_failure
      return unless failed_identity_verification?

      body = JSON.parse(response.to_s)
      body = {} unless body.is_a?(Hash)
      user = body.dig('data', 'api_user') || {}
      { message: body['message'].presence || "HTTP #{response_code}",
        username: user['username'], identity_code: user['identity_code'], subject: user['subject'] }
    rescue JSON::ParserError
      { message: "HTTP #{response_code}" }
    end
  end
end
