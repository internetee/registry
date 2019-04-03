require 'test_helper'

class RegistrantChangeMailerTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    ActionMailer::Base.deliveries.clear
  end

  def test_delivers_confirmation_request_email
    assert_equal 'shop.test', @domain.name
    assert_equal 'john@inbox.test', @domain.registrant.email

    email = RegistrantChangeMailer.confirm(domain: @domain,
                                           registrar: @domain.registrar,
                                           current_registrant: @domain.registrant,
                                           new_registrant: @domain.registrant).deliver_now

    assert_emails 1
    assert_equal ['john@inbox.test'], email.to
    assert_equal 'Kinnitustaotlus domeeni shop.test registreerija vahetuseks' \
                 ' / Application for approval for registrant change of shop.test', email.subject
  end

  def test_delivers_notification_email
    new_registrant = contacts(:william)
    assert_equal 'shop.test', @domain.name
    assert_equal 'william@inbox.test', new_registrant.email

    email = RegistrantChangeMailer.notice(domain: @domain,
                                          registrar: @domain.registrar,
                                          current_registrant: @domain.registrant,
                                          new_registrant: new_registrant).deliver_now

    assert_emails 1
    assert_equal ['william@inbox.test'], email.to
    assert_equal 'Domeeni shop.test registreerija vahetus protseduur on algatatud' \
                 ' / shop.test registrant change', email.subject
  end

  def test_delivers_confirmation_email
    new_registrant = contacts(:william)
    assert_equal 'shop.test', @domain.name
    assert_equal 'john@inbox.test', @domain.registrant.email
    assert_equal 'william@inbox.test', new_registrant.email

    email = RegistrantChangeMailer.confirmed(domain: @domain,
                                             old_registrant: new_registrant).deliver_now

    assert_emails 1
    assert_equal %w[john@inbox.test william@inbox.test], email.to
    assert_equal 'Domeeni shop.test registreerija vahetus teostatud' \
                 ' / Registrant change of shop.test has been finished', email.subject
  end

  def test_delivers_rejection_email
    assert_equal 'shop.test', @domain.name
    @domain.update!(pending_json: { new_registrant_email: 'william@inbox.test' })

    email = RegistrantChangeMailer.rejected(domain: @domain,
                                            registrar: @domain.registrar,
                                            registrant: @domain.registrant).deliver_now

    assert_emails 1
    assert_equal ['william@inbox.test'], email.to
    assert_equal 'Domeeni shop.test registreerija vahetuse taotlus tagasi lükatud' \
                 ' / shop.test registrant change declined', email.subject
  end

  def test_delivers_expiration_email
    assert_equal 'shop.test', @domain.name
    @domain.update!(pending_json: { new_registrant_email: 'william@inbox.test' })

    email = RegistrantChangeMailer.expired(domain: @domain,
                                           registrar: @domain.registrar,
                                           registrant: @domain.registrant).deliver_now

    assert_emails 1
    assert_equal ['william@inbox.test'], email.to
    assert_equal 'Domeeni shop.test registreerija vahetuse taotlus on tühistatud' \
                 ' / shop.test registrant change cancelled', email.subject
  end
end