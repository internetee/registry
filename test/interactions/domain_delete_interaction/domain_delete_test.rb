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

  # def test_sends_notification
  #   @domain.update!(delete_date: '2010-07-04')
  #   travel_to Time.zone.parse('2010-07-05')

  #   assert_difference '@domain.registrar.notifications.count', 1 do
  #     Domains::Delete::DoDelete.run(domain: @domain)
  #   end
  # end

  def test_preclean_pendings
    @domain.registrant_verification_token = "123"
    @domain.registrant_verification_asked_at = "123"
    @domain.preclean_pendings
    
    assert_nil @domain.registrant_verification_token
    assert_nil @domain.registrant_verification_asked_at
  end

  def test_clean_pendings 
    @domain.is_admin = true
    @domain.registrant_verification_token = "123"
    @domain.registrant_verification_asked_at = "123"
    @domain.pending_json = { delete: DomainStatus::PENDING_DELETE}
    @domain.update(statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION,
                              DomainStatus::PENDING_UPDATE,
                              DomainStatus::PENDING_DELETE,
                            ])
    @domain.status_notes[DomainStatus::PENDING_UPDATE] = '123'
    @domain.status_notes[DomainStatus::PENDING_DELETE] = '234'
    @domain.reload


    @domain.clean_pendings!
    @domain.reload

    assert @domain.is_admin
    assert_nil @domain.registrant_verification_token
    assert_nil @domain.registrant_verification_asked_at
    assert_equal @domain.pending_json, {}

    assert (not @domain.statuses.include? DomainStatus::PENDING_DELETE_CONFIRMATION)
    assert (not @domain.statuses.include? DomainStatus::PENDING_UPDATE)
    assert (not @domain.statuses.include? DomainStatus::PENDING_DELETE)

    assert_equal @domain.status_notes[DomainStatus::PENDING_UPDATE], ''
    assert_equal @domain.status_notes[DomainStatus::PENDING_DELETE], ''
  end
end
