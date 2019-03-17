require 'test_helper'

class DomainReleasableAuctionableTest < ActiveSupport::TestCase
  # Needed for `test_updates_whois` test because of `after_commit :update_whois_record` in Domain
  self.use_transactional_fixtures = false

  setup do
    @domain = domains(:shop)
    Domain.release_to_auction = true
  end

  teardown do
    Domain.release_to_auction = false
  end

  def test_sells_domain_at_auction
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 07:59'))
    travel_to Time.zone.parse('2010-07-05 08:00')

    Domain.release_domains

    assert @domain.domain_name.at_auction?
  end

  def test_deletes_registered_domain
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 07:59'))
    travel_to Time.zone.parse('2010-07-05 08:00')

    assert_difference 'Domain.count', -1 do
      Domain.release_domains
    end
  end

  def test_ignores_domains_with_delete_at_in_the_future_or_now
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 08:00'))
    travel_to Time.zone.parse('2010-07-05 08:00')

    assert_no_difference 'Domain.count' do
      Domain.release_domains
    end
    assert_not @domain.domain_name.at_auction?
  end

  def test_ignores_domains_with_server_delete_prohibited_status
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 07:59'),
                    statuses: [DomainStatus::SERVER_DELETE_PROHIBITED])
    travel_to Time.zone.parse('2010-07-05 08:00')

    assert_no_difference 'Domain.count' do
      Domain.release_domains
    end
    assert_not @domain.domain_name.at_auction?
  end
end
