require 'test_helper'

class DomainReleasableAuctionableTest < ActiveSupport::TestCase
  # Needed for `test_updates_whois` test because of `after_commit :update_whois_record` in Domain
  self.use_transactional_tests = false

  setup do
    @domain = domains(:shop)
    Domain.release_to_auction = true
  end

  teardown do
    Domain.release_to_auction = false
  end

  def test_sells_domain_at_auction
    @domain.update!(delete_date: '2010-07-04')
    travel_to Time.zone.parse('2010-07-05')

    Domain.release_domains

    assert @domain.domain_name.at_auction?
  end

  def test_skips_auction_when_domains_is_blocked
    assert_equal 'shop.test', @domain.name
    blocked_domains(:one).update!(name: 'shop.test')

    @domain.release

    assert_not @domain.domain_name.at_auction?
  end

  def test_skips_auction_when_domains_is_reserved
    assert_equal 'shop.test', @domain.name
    reserved_domains(:one).update!(name: 'shop.test')

    @domain.release

    assert_not @domain.domain_name.at_auction?
  end

  def test_sells_domains_with_scheduled_force_delete_procedure_at_auction
    @domain.update!(force_delete_date: '2010-07-05')
    travel_to Time.zone.parse('2010-07-05')

    Domain.release_domains

    assert @domain.domain_name.at_auction?
  end

  def test_deletes_registered_domain
    @domain.update!(delete_date: '2010-07-04')
    travel_to Time.zone.parse('2010-07-05')

    assert_difference 'Domain.count', -1 do
      Domain.release_domains
    end
  end

  def test_notifies_registrar
    @domain.update!(delete_date: '2010-07-04')
    travel_to Time.zone.parse('2010-07-05')

    assert_difference -> { @domain.registrar.notifications.count } do
      Domain.release_domains
    end
  end

  def test_ignores_domains_with_delete_date_in_the_future
    @domain.update!(delete_date: '2010-07-06')
    travel_to Time.zone.parse('2010-07-05')

    assert_no_difference 'Domain.count' do
      Domain.release_domains
    end
    assert_not @domain.domain_name.at_auction?
  end

  def test_ignores_domains_with_server_delete_prohibited_status
    @domain.update!(delete_date: '2010-07-04', statuses: [DomainStatus::SERVER_DELETE_PROHIBITED])
    travel_to Time.zone.parse('2010-07-05')

    assert_no_difference 'Domain.count' do
      Domain.release_domains
    end
    assert_not @domain.domain_name.at_auction?
  end
end
