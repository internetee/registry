require 'test_helper'

class DomainDeleteTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_discards_domains_with_past_delete_date
    @domain.update!(delete_date: '2010-07-04')
    travel_to Time.zone.parse('2010-07-05')

    Domains::Delete::DoDelete.run(domain: @domain)

    assert @domain.destroyed?
  end

  def test_sends_notification
    @domain.update!(delete_date: '2010-07-04')
    travel_to Time.zone.parse('2010-07-05')

    assert_difference '@domain.registrar.notifications.count', 1 do
      Domains::Delete::DoDelete.run(domain: @domain)
    end
  end
end
