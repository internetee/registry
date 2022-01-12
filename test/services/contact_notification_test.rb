require 'test_helper'

class ContactNotificationTest < ActionMailer::TestCase

  setup do
    @domain = domains(:shop)
    @text = 'text'
  end

  def test_notify_registrar
    assert_difference -> { @domain.registrar.notifications.count } do
      ContactNotification.notify_registrar(domain: @domain, text: @text)
    end
  end

  def test_notify_tech_contacts_that_nameserver_is_broken
    ContactNotification.notify_tech_contact(domain: @domain, reason: 'nameserver')
    assert_equal @domain.tech_contacts.count, 2
    assert_emails 2
  end

  def test_notify_tech_contacts_that_dnssec_is_broken
    ContactNotification.notify_tech_contact(domain: @domain, reason: 'dnssec')
    assert_equal @domain.tech_contacts.count, 2
    assert_emails 2
  end
end

