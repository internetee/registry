require 'test_helper'

class DomainExpireMailerTest < ActionMailer::TestCase
  def test_delivers_domain_expiration_email
    domain = domains(:shop)
    assert_equal 'shop.test', domain.name

    email = DomainExpireMailer.expired(domain: domain, registrar: domain.registrar).deliver_now

    assert_emails 1
    assert_equal 'Domeen shop.test on aegunud / Domain shop.test has expired' \
      ' / Срок действия домена shop.test истек', email.subject
  end
end