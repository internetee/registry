require 'test_helper'

class EmailCheckTest < ActiveSupport::TestCase

  setup do
    WebMock.disable_net_connect!

    @contact = contacts(:john)
  end

  def test_invalid_email_in_mx_level_with_a_and_aaaa_records
    trumail_results = OpenStruct.new(success: false,
                                     email: @contact.email,
                                     domain: "box.tests",
                                     errors: {:mx=>"target host(s) not found"},
                                     )

    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_results)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([true])

    action = Actions::EmailCheck.new(email: @contact.email,
                                     validation_eventable: @contact,
                                     check_level: 'mx')
    action.call

    assert_equal @contact.validation_events.count, 1
    assert @contact.validation_events.last.success
  end

  def test_invalid_email_in_mx_level_with_empty_a_and_aaaa_records
    trumail_results = OpenStruct.new(success: false,
                                     email: @contact.email,
                                     domain: "box.tests",
                                     errors: {:mx=>"target host(s) not found"},
                                     )

    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_results)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([])

    action = Actions::EmailCheck.new(email: @contact.email,
                                     validation_eventable: @contact,
                                     check_level: 'mx')
    action.call

    assert_equal @contact.validation_events.count, 1
    refute @contact.validation_events.last.success
  end

  def test_should_remove_invalid_validation_record_if_there_count_more_than_three
    trumail_results = OpenStruct.new(success: false,
                                     email: @contact.email,
                                     domain: "box.tests",
                                     errors: {:mx=>"target host(s) not found"},
                                     )

    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_results)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([])

    action = Actions::EmailCheck.new(email: @contact.email,
                                     validation_eventable: @contact,
                                     check_level: 'mx')
    3.times do
      action.call
    end

    assert_equal @contact.validation_events.count, 3
    refute @contact.validation_events.last.success

    3.times do
      action.call
    end

    assert_equal @contact.validation_events.count, 3
    refute @contact.validation_events.last.success
  end

  def test_should_remove_valid_validation_record_if_there_count_more_than_one
    trumail_results = OpenStruct.new(success: false,
                                     email: @contact.email,
                                     domain: "box.tests",
                                     errors: {:mx=>"target host(s) not found"},
                                     )

    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_results)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([true])

    action = Actions::EmailCheck.new(email: @contact.email,
                                     validation_eventable: @contact,
                                     check_level: 'mx')

    3.times do
      action.call
    end

    assert_equal @contact.validation_events.count, 1
    assert @contact.validation_events.last.success
  end
end
