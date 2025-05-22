require 'test_helper'

class BaseTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
    @domain_airport = domains(:airport)
    travel_to Time.zone.parse('2010-07-05 00:30:00')
  end

  def test_hold_domains_force_delete_email
    @domain.update!(statuses: [DomainStatus::SERVER_HOLD])
    @domain.update!(expire_time: Time.zone.now + 1.year)

    registrant = @domain.registrant
    registrant.update!(email: "#{registrant.email.split('@').first}@#{@domain.name}")

    Domains::ForceDeleteEmail::Base.run(email: registrant.email)

    @domain.reload

    assert_not @domain.force_delete_scheduled?
  end

  def test_more_that_year_until_valid_to_date
    refute @domain_airport.force_delete_scheduled?
    @domain_airport.update!(valid_to: Time.zone.now + 3.years + 1.month + 1.day)
    @domain_airport.reload
    prepare_contact

    contact = @domain_airport.admin_contacts.first
    Domains::ForceDeleteEmail::Base.run(email: contact.email)

    @domain_airport.reload

    assert @domain_airport.force_delete_scheduled?
    assert @domain_airport.valid_to > Time.zone.now + 1.year
    assert_equal @domain_airport.force_delete_start.to_date, (Time.zone.now + 1.month + 1.day).to_date
    assert_equal @domain_airport.force_delete_date, (@domain_airport.force_delete_start +
                                                    Setting.expire_warning_period.days +
                                                    Setting.redemption_grace_period.days).to_date
  end

  def test_more_that_year_until_valid_to_date_but_month_is_previous
    refute @domain_airport.force_delete_scheduled?
    @domain_airport.update!(valid_to: Time.zone.now + 3.years - 1.month - 4.days)
    @domain_airport.reload
    prepare_contact

    contact = @domain_airport.admin_contacts.first

    Domains::ForceDeleteEmail::Base.run(email: contact.email)
    @domain_airport.reload

    assert @domain_airport.force_delete_scheduled?
    assert @domain_airport.valid_to > Time.zone.now + 1.year
    assert_equal @domain_airport.force_delete_start.to_date, (Time.zone.now + 1.year - 1.month - 4.days).to_date
    assert_equal @domain_airport.force_delete_date, (@domain_airport.force_delete_start +
                                                    Setting.expire_warning_period.days +
                                                    Setting.redemption_grace_period.days).to_date
  end

  private

  def prepare_contact
    assert_not @domain_airport.force_delete_scheduled?
    email = '~@internet.ee'

    contact = @domain_airport.admin_contacts.first
    contact.update_attribute(:email, email)
    (ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD).times do
      contact.verify_email
    end
    contact.reload

    refute contact.validation_events.last.success?
    assert contact.need_to_start_force_delete?
  end
end
