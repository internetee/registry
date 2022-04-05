require 'test_helper'

class BaseTest < ActiveSupport::TestCase
  def test_hold_domains_force_delete_email
    domain = domains(:shop)
    domain.update!(statuses: [DomainStatus::SERVER_HOLD])
    domain.update!(expire_time: Time.zone.now + 1.year)

    registrant = domain.registrant
    registrant.update!(email: "#{registrant.email.split('@').first}@#{domain.name}")

    Domains::ForceDeleteEmail::Base.run(email: registrant.email)

    domain.reload

    assert_not domain.force_delete_scheduled?
  end
end
