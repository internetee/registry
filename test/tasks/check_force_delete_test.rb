require 'test_helper'

class CheckForceDeleteTaskTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @contact = contacts(:john)
    @invalid_contact = contacts(:invalid_email)
  end

  def test_enque_force_delete_when_three_invalid_records_by_mx
    trumail_results = OpenStruct.new(success: false,
                                     email: @contact.email,
                                     domain: 'box.tests',
                                     errors: { mx: 'target host(s) not found' })

    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_results)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([])

    action = Actions::EmailCheck.new(email: @contact.email,
                                     validation_eventable: @contact,
                                     check_level: 'mx')
    3.times do
      action.call
    end

    run_task

    assert_enqueued_jobs 1
    assert_enqueued_with(job: CheckForceDeleteJob, args: [[@contact.id]])
  end

  def test_enque_force_delete_when_invalid_record_by_regex
    @invalid_contact.verify_email
    run_task

    assert_enqueued_jobs 1
    assert_enqueued_with(job: CheckForceDeleteJob, args: [[@invalid_contact.id]])
  end

  def test_not_enque_force_delete
    trumail_results = OpenStruct.new(success: false,
                                     email: @contact.email,
                                     domain: 'box.tests',
                                     errors: { mx: 'target host(s) not found' })

    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_results)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([])

    action = Actions::EmailCheck.new(email: @contact.email,
                                     validation_eventable: @contact,
                                     check_level: 'mx')
    2.times do
      action.call
    end

    assert_enqueued_jobs 0
  end

  private

  def run_task
    Rake::Task['check_force_delete'].execute
  end
end
