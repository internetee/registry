require 'test_helper'

class AccreditationCenterMailerTest < ActionMailer::TestCase
  setup do
    @admin = users(:admin)
    @registrar = registrars(:bestnames)
  end

  def test_send_mails_for_admins
    email = AccreditationCenterMailer.test_was_successfully_passed_admin(@admin.email)
                         .deliver_now

    assert_emails 1
    assert_equal [@admin.email], email.to
  end

  def test_send_mails_for_registrar
    email = AccreditationCenterMailer.test_was_successfully_passed_registrar(@registrar.email)
                                     .deliver_now

    assert_emails 1
    assert_equal [@registrar.email], email.to
  end

  def test_send_mails_month_before
    email = AccreditationCenterMailer.test_results_will_expired_in_one_month(@registrar.email)
                                     .deliver_now

    assert_emails 1
    assert_equal [@registrar.email], email.to
  end

  def test_send_mails_if_accredation_date_is_expired
    email = AccreditationCenterMailer.test_results_are_expired(@registrar.email)
                                     .deliver_now

    assert_emails 1
    assert_equal [@registrar.email], email.to
  end
end
