require 'test_helper'

class DomainExpireMailerTest < ActionMailer::TestCase
  def test_delivers_domain_expiration_email
    domain = domains(:shop)
    assert_equal 'shop.test', domain.name

    email = DomainExpireMailer.expired(domain: domain, registrar: domain.registrar).deliver_now

    assert_emails 1
    assert_equal I18n.t("domain_expire_mailer.expired.subject", domain_name: domain.name),
                 email.subject
  end

  def test_delivers_domain_expiration_soft_email
    domain = domains(:shop)
    assert_equal 'shop.test', domain.name

    email = DomainExpireMailer.expired_soft(domain: domain, registrar: domain.registrar).deliver_now

    assert_emails 1
    assert_equal I18n.t("domain_expire_mailer.expired_soft.subject", domain_name: domain.name),
                 email.subject
  end
end
