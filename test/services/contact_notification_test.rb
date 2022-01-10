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

  def test_notify_tech_contacts
    ContactNotification.notify_tech_contact(domain: @domain, text: @text)
    assert_equal @domain.tech_contacts.count, 2
    assert_emails 2
  end
end

