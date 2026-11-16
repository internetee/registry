require 'test_helper'

class ApiLog::ReppLogTest < ActiveSupport::TestCase
  APPROVE_PATH = '/repp/v1/api_users/approve_verification/1'.freeze

  test 'detects failed identity approvals only' do
    assert ApiLog::ReppLog.new(request_path: APPROVE_PATH, response_code: '400').failed_identity_verification?
    assert_not ApiLog::ReppLog.new(request_path: APPROVE_PATH, response_code: '200').failed_identity_verification?
    assert_not ApiLog::ReppLog.new(request_path: '/repp/v1/contacts', response_code: '400').failed_identity_verification?
  end

  test 'extracts failure details from the response' do
    response = { message: 'Identity EE1 is already linked to API user bob at this registrar',
                 data: { verification_failed: true,
                         api_user: { username: 'machine', identity_code: nil, subject: 'EE1' } } }.to_json
    failure = ApiLog::ReppLog.new(request_path: APPROVE_PATH, response_code: '400', response: response)
                             .identity_verification_failure

    assert_equal 'machine', failure[:username]
    assert_equal 'EE1', failure[:subject]
    assert_includes failure[:message], 'bob'
  end

  test 'falls back to the status code when the response has no details' do
    failure = ApiLog::ReppLog.new(request_path: APPROVE_PATH, response_code: '500', response: 'null')
                             .identity_verification_failure

    assert_equal 'HTTP 500', failure[:message]
  end
end
