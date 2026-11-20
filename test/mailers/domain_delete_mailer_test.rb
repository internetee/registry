require 'test_helper'

class DomainDeleteMailerTest < ActionMailer::TestCase
  setup do
    @domain = domains(:shop)
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
                                      template_name: @domain.notification_template).deliver_now

    assert_emails 1
    assert_equal ['legal@registry.test'], email.from
    assert @domain.force_delete_contact_emails.sort == email.to.sort
    assert_equal 'Domeen shop.test on kustutusmenetluses' \
                 ' / Domain shop.test is in deletion process', email.subject
  end

  def test_forced_invalid_email
    @domain.update(template_name: 'invalid_email')
    @domain.reload

    email = DomainDeleteMailer.forced(domain: @domain,
                                      registrar: @domain.registrar,
                                      registrant: @domain.registrant,
                                      template_name: @domain.template_name).deliver_now

    assert_emails 1
    assert_equal ['legal@registry.test'], email.from
    assert @domain.force_delete_contact_emails.sort == email.to.sort
    assert_equal 'Domeen shop.test on kustutusmenetluses' \
                 ' / Domain shop.test is in deletion process', email.subject
  end

  def test_forced_deceased_admin_contact
    email = DomainDeleteMailer.forced(domain: @domain,
                                      registrar: @domain.registrar,
                                      registrant: @domain.registrant,
                                      template_name: 'deceased_admin_contact').deliver_now

    assert_emails 1
    assert_includes email.text_part.body.to_s, 'halduskontakt on surnud'
    assert_includes email.html_part.body.to_s, 'administrative contact of the domain shop.test has died'
  end

  def test_forced_deceased_admin_contact_names_dates_not_day_count
    Setting.expire_warning_period = 15
    @domain.update_columns(statuses: [DomainStatus::FORCE_DELETE],
                           force_delete_start: Time.zone.parse('2027-03-01'),
                           force_delete_date: Date.new(2027, 4, 15))

    email = DomainDeleteMailer.forced(domain: @domain,
                                      registrar: @domain.registrar,
                                      registrant: @domain.registrant,
                                      template_name: 'deceased_admin_contact').deliver_now

    text = email.text_part.body.to_s
    assert_includes text, 'Kui uut halduskontakti ei ole lisatud enne 2027-04-15'
    assert_includes text, 'internetis kättesaadav kuni 2027-03-16'
    assert_includes text, 'If no new administrative contact is added before 2027-04-15'
    assert_includes text, 'remain available on the Internet until 2027-03-16'
    assert_not_includes text, 'päeva jooksul'
    assert_not_includes text, 'päeva pikkuse'
  end

  def test_forced_deceased_person_uses_private_person_letter
    email = DomainDeleteMailer.forced(domain: @domain,
                                      registrar: @domain.registrar,
                                      registrant: @domain.registrant,
                                      template_name: 'deceased_person').deliver_now

    assert_includes email.text_part.body.to_s, 'on surnud ja sellest on möödunud vähemalt 6 kuud'
  end
end
