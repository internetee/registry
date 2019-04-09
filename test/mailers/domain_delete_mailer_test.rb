require 'test_helper'

class DomainDeleteMailerTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    ActionMailer::Base.deliveries.clear
  end

  def test_force_delete_templates
    assert_equal %w[private_person legal_person], DomainDeleteMailer.force_delete_templates
  end

  def test_delivers_domain_delete_confirmation_email
    assert_equal 'shop.test', @domain.name
    assert_equal 'john@inbox.test', @domain.registrant.email

    email = DomainDeleteMailer.confirmation(domain: @domain,
                                            registrar: @domain.registrar,
                                            registrant: @domain.registrant).deliver_now

    assert_emails 1
    assert_equal ['john@inbox.test'], email.to
    assert_equal 'Kinnitustaotlus domeeni shop.test kustutamiseks .ee registrist' \
                 ' / Application for approval for deletion of shop.test', email.subject
  end

  def test_delivers_domain_force_delete_email
    assert_equal 'shop.test', @domain.name
    assert_equal 'john@inbox.test', @domain.registrant.email
    assert_equal 'jane@mail.test', @domain.admin_contacts.first.email

    email = DomainDeleteMailer.forced(domain: @domain,
                                      registrar: @domain.registrar,
                                      registrant: @domain.registrant,
                                      template_name: DomainDeleteMailer.force_delete_templates
                                                       .first).deliver_now

    assert_emails 1
    assert_equal %w[jane@mail.test john@inbox.test], email.to
    assert_equal 'Domeen shop.test on kustutusmenetluses' \
                 ' / Domain shop.test is in deletion process' \
                 ' / Домен shop.test в процессе удаления', email.subject
  end
end