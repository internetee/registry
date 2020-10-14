require 'test_helper'

class DomainDeleteMailerTest < ActionMailer::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_force_delete_templates
    assert_equal %w[private_person legal_person], DomainDeleteMailer.force_delete_templates
  end

  def test_delivers_confirmation_request_email
    assert_equal 'shop.test', @domain.name
    assert_equal 'john@inbox.test', @domain.registrant.email

    email = DomainDeleteMailer.confirmation_request(domain: @domain,
                                                    registrar: @domain.registrar,
                                                    registrant: @domain.registrant).deliver_now

    assert_emails 1
    assert_equal ['john@inbox.test'], email.to
    assert_equal 'Kinnitustaotlus domeeni shop.test kustutamiseks .ee registrist' \
                 ' / Application for approval for deletion of shop.test', email.subject
  end

  def test_delivers_accepted_email
    assert_equal 'shop.test', @domain.name
    assert_equal 'john@inbox.test', @domain.registrant.email

    email = DomainDeleteMailer.accepted(@domain).deliver_now

    assert_emails 1
    assert_equal ['john@inbox.test'], email.to
    assert_equal 'Domeeni shop.test kustutatud' \
                 ' / shop.test deleted', email.subject
  end

  def test_delivers_rejected_email
    assert_equal 'shop.test', @domain.name
    assert_equal 'john@inbox.test', @domain.registrant.email

    email = DomainDeleteMailer.rejected(@domain).deliver_now

    assert_emails 1
    assert_equal ['john@inbox.test'], email.to
    assert_equal 'Domeeni shop.test kustutamise taotlus tagasi lükatud' \
                 ' / shop.test deletion declined', email.subject
  end

  def test_delivers_expired_email
    assert_equal 'shop.test', @domain.name
    assert_equal 'john@inbox.test', @domain.registrant.email

    email = DomainDeleteMailer.expired(@domain).deliver_now

    assert_emails 1
    assert_equal ['john@inbox.test'], email.to
    assert_equal 'Domeeni shop.test kustutamise taotlus on tühistatud' \
                 ' / shop.test deletion cancelled', email.subject
  end

  def test_delivers_domain_force_delete_email
    assert_equal 'shop.test', @domain.name
    assert_equal 'john@inbox.test', @domain.registrant.email
    assert_equal 'jane@mail.test', @domain.admin_contacts.first.email
    assert_equal 'legal@registry.test', ENV['action_mailer_force_delete_from']

    email = DomainDeleteMailer.forced(domain: @domain,
                                      registrar: @domain.registrar,
                                      registrant: @domain.registrant,
                                      template_name: DomainDeleteMailer.force_delete_templates
                                                       .first).deliver_now

    assert_emails 1
    assert_equal ['legal@registry.test'], email.from
    assert @domain.force_delete_contact_emails.sort == email.to.sort
    assert_equal 'Domeen shop.test on kustutusmenetluses' \
                 ' / Domain shop.test is in deletion process' \
                 ' / Домен shop.test в процессе удаления', email.subject
  end
end
