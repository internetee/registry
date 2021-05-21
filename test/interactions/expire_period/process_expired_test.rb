require 'test_helper'

class StartTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    @domain.update(expire_time: Time.zone.now - 1.day)
    ActionMailer::Base.deliveries.clear
  end

  def test_expired_domain_contact_emails_should_not_contain_tech_contacts
    contact_list = []
    @domain.tech_contacts.each do |contact|
      contact_list << contact.email
    end

    email_address = @domain.expired_domain_contact_emails
    email = DomainExpireMailer.expired_soft(domain: @domain,
                                            registrar: @domain.registrar,
                                            email: email_address).deliver_now

    email.to.each do |received|
      assert_not contact_list.include? received
    end
  end
end
