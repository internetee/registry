require 'test_helper'

class EppResponseResultCodeTest < ActiveSupport::TestCase
  def test_creates_code_by_key
    key = :completed_successfully
    assert_includes Epp::Response::Result::Code.codes.keys, key

    assert_kind_of Epp::Response::Result::Code, Epp::Response::Result::Code.key(key)
  end

  def test_creates_new_code_by_string_value
    code_value = Epp::Response::Result::Code.codes.values.first
    code = Epp::Response::Result::Code.new(code_value.to_s)
    assert_equal code_value, code.value
  end

  def test_invalid_code_value
    invalid_code_value = 0000
    refute_includes Epp::Response::Result::Code.codes.values, invalid_code_value

    e = assert_raises ArgumentError do
      Epp::Response::Result::Code.new(invalid_code_value)
    end
    assert_equal "Invalid value: #{invalid_code_value}", e.message
  end

  def test_returns_code_values
    codes = {
      completed_successfully: 1000,
      completed_successfully_action_pending: 1001,
      completed_successfully_no_messages: 1300,
      completed_successfully_ack_to_dequeue: 1301,
      completed_successfully_ending_session: 1500,
      unknown_command: 2000,
      syntax_error: 2001,
      use_error: 2002,
      required_parameter_missing: 2003,
      parameter_value_range_error: 2004,
      parameter_value_syntax_error: 2005,
      billing_failure: 2104,
      unimplemented: 2101,
      object_is_not_eligible_for_renewal: 2105,
      object_is_not_eligible_for_transfer: 2106,
      authorization_error: 2201,
      invalid_authorization_information: 2202,
      object_does_not_exist: 2303,
      object_status_prohibits_operation: 2304,
      object_association_prohibits_operation: 2305,
      parameter_value_policy_error: 2306,
      data_management_policy_violation: 2308,
      command_failed: 2400,
      authentication_error_server_closing_connection: 2501,
    }
    assert_equal codes, Epp::Response::Result::Code.codes
  end

  def test_returns_default_descriptions
    descriptions = {
      1000 => 'Command completed successfully',
      1001 => 'Command completed successfully; action pending',
      1300 => 'Command completed successfully; no messages',
      1301 => 'Command completed successfully; ack to dequeue',
      1500 => 'Command completed successfully; ending session',
      2000 => 'Unknown command',
      2001 => 'Command syntax error',
      2002 => 'Command use error',
      2003 => 'Required parameter missing',
      2004 => 'Parameter value range error',
      2005 => 'Parameter value syntax error',
      2101 => 'Unimplemented command',
      2104 => 'Billing failure',
      2105 => 'Object is not eligible for renewal',
      2106 => 'Object is not eligible for transfer',
      2201 => 'Authorization error',
      2202 => 'Invalid authorization information',
      2303 => 'Object does not exist',
      2304 => 'Object status prohibits operation',
      2305 => 'Object association prohibits operation',
      2306 => 'Parameter value policy error',
      2308 => 'Data management policy violation',
      2400 => 'Command failed',
      2501 => 'Authentication error; server closing connection',
    }
    assert_equal descriptions, Epp::Response::Result::Code.default_descriptions
  end

  def test_equality
    assert_equal Epp::Response::Result::Code.new(1000), Epp::Response::Result::Code.new(1000)
  end
end
