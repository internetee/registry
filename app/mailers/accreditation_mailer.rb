class AccreditationMailer < ApplicationMailer
  def test_was_successfully_passed_admin(email, registrar = nil)
    @registrar = registrar
    mail(to: email, subject: default_i18n_subject)
  end

  def test_was_successfully_passed_registrar(email)
    mail(to: email, subject: default_i18n_subject)
  end

  def test_results_will_expired_in_one_month(email)
    mail(to: email, subject: default_i18n_subject)
  end

  def test_results_are_expired(email)
    mail(to: email, subject: default_i18n_subject)
  end
end
