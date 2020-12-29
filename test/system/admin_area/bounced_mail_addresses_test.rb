require 'application_system_test_case'

class AdminBouncedMailAddressesTest < ApplicationSystemTestCase
  include ActionView::Helpers::NumberHelper

  def setup
    @bounced_mail = bounced_mail_addresses(:one)
    @original_default_language = Setting.default_language
    sign_in users(:admin)
  end

  def teardown
    Setting.default_language = @original_default_language
  end

  def test_shows_bounced_emails
    visit admin_bounced_mail_addresses_path
    assert_text @bounced_mail.status
    assert_text @bounced_mail.action
    assert_text @bounced_mail.diagnostic
    assert_text @bounced_mail.email
  end

  def test_shows_detailed_bounced_email
    visit admin_bounced_mail_address_path(@bounced_mail)
    assert_text @bounced_mail.status
    assert_text @bounced_mail.action
    assert_text @bounced_mail.diagnostic
    assert_text @bounced_mail.email

    assert_text @bounced_mail.message_id
  end

  def test_deletes_registrar
    visit admin_bounced_mail_address_path(@bounced_mail)
    click_on 'Destroy'

    assert_text 'Bounced mail address was successfully destroyed.'
  end
end
