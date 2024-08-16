require 'test_helper'

class RetryGreylistedEmailsJobTest < ActiveJob::TestCase
  def setup
    @contact = contacts(:john)
    @contact.validation_events.destroy_all
    @greylisted_event = ValidationEvent.create(
      validation_eventable: @contact,
      event_type: :email_validation,
      success: false,
      event_data: {
        email: @contact.email,
        domain: @contact.email.split('@').last,
        mail_servers: ["194.19.134.80", "185.138.56.208"],
        errors: { smtp: "smtp error" },
        smtp_debug: [{
          host: "194.19.134.80",
          email: @contact.email,
          attempts: nil,
          response: {
            port_opened: true,
            connection: true,
            helo: true,
            mailfrom: { status: "250", string: "250 2.1.0 Ok\n" },
            rcptto: false,
            errors: { rcptto: "451 4.7.1 <#{@contact.email}>: Recipient address rejected: Greylisted for 1 minutes\n" }
          },
          configuration: {
            smtp_port: 25,
            verifier_email: "no-reply@example.com",
            verifier_domain: "example.com",
            response_timeout: 1,
            connection_timeout: 1
          }
        }],
        check_level: "smtp"
      }
    )
    @contact.reload
  end

  test 'performs retry for greylisted emails and succeeds' do
    mock_truemail_success do
      assert_no_difference 'ValidationEvent.count' do
        RetryGreylistedEmailsJob.perform_now
      end
    end
  
    @contact.reload
    assert @contact.validation_events.last.success?
    assert_nil @contact.validation_events.last.event_data.dig('smtp_debug', 0, 'response', 'errors', 'rcptto')
  end
  
  def test_marks_email_as_invalid_after_max_retries
    mock_truemail_failure(RetryGreylistedEmailsJob::MAX_RETRY_ATTEMPTS) do
      assert_no_difference 'ValidationEvent.count' do
        RetryGreylistedEmailsJob.perform_now
      end
    end
  
    @contact.reload
    last_event = @contact.validation_events.last
    refute last_event.success?
    
    error_message = last_event.event_data['errors']&.dig('smtp') ||
                    last_event.event_data['error'] ||
                    last_event.event_data.dig('smtp_debug', 0, 'response', 'errors', 'rcptto')
    
    assert_equal 'Max retry count exceeded', error_message
  end
  
  test 'retries until email is not greylisted' do
    mock_truemail_success_after_failures(3) do
      assert_no_difference 'ValidationEvent.count' do
        RetryGreylistedEmailsJob.perform_now
      end
    end
  
    @contact.reload
    assert @contact.validation_events.last.success?
    assert_nil @contact.validation_events.last.event_data.dig('smtp_debug', 0, 'response', 'errors', 'rcptto')
  end

  private

  def mock_truemail_success
  result = mock_truemail_result(true)
  Truemail.stub :validate, result do
    yield if block_given?
  end
end

def mock_truemail_failure(times = 1)
  results = Array.new(times) { mock_truemail_result(false) }
  Truemail.stub :validate, ->(*args) { results.shift || mock_truemail_result(false) } do
    yield if block_given?
  end
end

def mock_truemail_success_after_failures(failure_count)
  results = Array.new(failure_count) { mock_truemail_result(false) }
  results << mock_truemail_result(true)
  Truemail.stub :validate, ->(*args) { results.shift || mock_truemail_result(true) } do
    yield if block_given?
  end
end

def mock_truemail_result(success)
  OpenStruct.new(
    result: OpenStruct.new(
      success?: success,
      email: @contact.email,
      domain: @contact.email.split('@').last,
      mail_servers: ["194.19.134.80", "185.138.56.208"],
      errors: success ? {} : { smtp: "smtp error" },
      smtp_debug: [
        OpenStruct.new(
          host: "194.19.134.80",
          email: @contact.email,
          attempts: nil,
          response: OpenStruct.new(
            port_opened: true,
            connection: true,
            helo: true,
            mailfrom: OpenStruct.new(status: "250", string: "250 2.1.0 Ok\n"),
            rcptto: success,
            errors: success ? {} : { rcptto: "451 4.7.1 <#{@contact.email}>: Recipient address rejected: Greylisted for 1 minutes\n" }
          ),
          configuration: OpenStruct.new(
            smtp_port: 25,
            verifier_email: "no-reply@example.com",
            verifier_domain: "example.com",
            response_timeout: 1,
            connection_timeout: 1
          )
        )
      ]
    )
  )
end
end