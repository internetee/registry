class AccreditationCenterMailer < ApplicationMailer
  def test_was_successfully_passed_admin(email)
    subject = 'Test passed admin'
    mail(to: email, subject: subject)
  end

  def test_was_successfully_passed_registrar(email)
    subject = 'Test passed registrar'
    mail(to: email, subject: subject)
  end

  def test_results_will_expired_in_one_month(email)
    subject = 'Test will expired in one month'
    mail(to: email, subject: subject)
  end

  def test_results_are_expired(email)
    subject = 'Test are expired'
    mail(to: email, subject: subject)
  end
end
