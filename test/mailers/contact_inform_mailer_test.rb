require 'test_helper'

class ContactInformMailerTest < ActionMailer::TestCase
  setup do
    @contact = contacts(:john)
  end

  def test_liquidation_email
    assert_equal 'john-001', @contact.code
    assert_equal 'john@inbox.test', @contact.email

    email = ContactInformMailer.company_liquidation(contact: @contact).deliver_now

    assert_emails 1

    assert_equal %w[john@inbox.test], email.to
    assert_equal 'Kas soovite oma .ee domeeni säilitada? / Do you wish to preserve your .ee registration?', email.subject
  end
end
