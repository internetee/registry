require 'test_helper'

class EmailCheckTest < ActiveSupport::TestCase
  setup do
    WebMock.disable_net_connect!

    @contact = contacts(:john)
  end

  def test_validates_regex_email_format
    valid_emails = [
      'user@domain.com',
      'user_@domain.com',
      'user.name@domain.com',
      'hello.world@example.com',
      '_user.email@domain.com',
      '__user.email@domain.com',
    ]

    valid_emails.each_with_index do |email, index|
      assert Actions::EmailCheck.new(email: email, validation_eventable: @contact, check_level: 'regex').call
    end

    invalid_emails = [
      'user..name@domain.com',
      '.user@domain.com',
      'user.@domain.com',
      'us"er@domain.com',
      'user@domain..com'
    ]

    invalid_emails.each do |email|
      refute Actions::EmailCheck.new(email: email, validation_eventable: @contact, check_level: 'regex').call
    end
  end

  def test_invalid_email_in_mx_level_with_a_and_aaaa_records
    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_result)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([true])

    Actions::EmailCheck.new(email: @contact.email,
                            validation_eventable: @contact,
                            check_level: 'mx').call

    assert_equal @contact.validation_events.count, 1
    assert @contact.validation_events.last.success
  end

  def test_invalid_email_in_mx_level_with_empty_a_and_aaaa_records
    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_result)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([])

    Actions::EmailCheck.new(email: @contact.email,
                            validation_eventable: @contact,
                            check_level: 'mx').call

    assert_equal @contact.validation_events.count, 1
    refute @contact.validation_events.last.success
  end

  def test_should_remove_invalid_validation_records_if_there_count_more_than_three
    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_result)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([])

    action = Actions::EmailCheck.new(email: @contact.email,
                                     validation_eventable: @contact,
                                     check_level: 'mx')
    3.times { action.call }

    assert_equal @contact.validation_events.count, 3
    refute @contact.validation_events.last.success

    3.times { action.call }

    assert_equal @contact.validation_events.count, 3
    refute @contact.validation_events.last.success
  end

  def test_should_remove_valid_validation_record_if_there_count_more_than_one
    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_result)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([true])

    action = Actions::EmailCheck.new(email: @contact.email,
                                     validation_eventable: @contact,
                                     check_level: 'mx')

    3.times { action.call }

    assert_equal @contact.validation_events.count, 1
    assert @contact.validation_events.last.success
  end

  def test_should_remove_old_record_if_validation_pass_the_limit
    action = Actions::EmailCheck.new(email: @contact.email,
                                     validation_eventable: @contact,
                                     check_level: 'mx')

    action.stub :check_email, trumail_result do
      4.times do
        action.call
      end
    end

    assert_equal @contact.validation_events.count, 3
  end

  def test_should_remove_old_record_if_multiple_contacts_has_the_same_email
    contact_two = contacts(:william)
    contact_two.update(email: @contact.email)
    contact_two.reload

    action = Actions::EmailCheck.new(email: @contact.email,
                                     validation_eventable: @contact,
                                     check_level: 'mx')

    action.stub :check_email, trumail_result do
      4.times do
        action.call
      end
    end

    assert_equal @contact.validation_events.count, 3
    assert_equal contact_two.validation_events.count, 3
  end

  def test_should_test_email_with_punnycode
    email = "info@xn--energiathus-mfb.ee"
    result = Actions::SimpleMailValidator.run(email: email, level: :mx)

    assert result
  end

  private

  def trumail_result
    OpenStruct.new(success: false,
                   email: @contact.email,
                   domain: 'box.tests',
                   errors: { mx: 'target host(s) not found' })
  end
end
