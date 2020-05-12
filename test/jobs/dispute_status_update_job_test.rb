require "test_helper"

class DisputeStatusUpdateJobTest < ActiveSupport::TestCase
  setup do
    travel_to Time.zone.parse('2010-10-05')
  end

  def test_nothing_is_raised
    assert_nothing_raised do
      DisputeStatusUpdateJob.run
    end
  end

  def test_whois_data_added_when_dispute_activated
    dispute = disputes(:future)
    DisputeStatusUpdateJob.run

    whois_record = Whois::Record.find_by(name: dispute.domain_name)
    assert whois_record.present?
    assert_includes whois_record.json['status'], 'disputed'
  end

  def test_on_expiry_unregistered_domain_is_sent_to_auction
    dispute = disputes(:active)
    dispute.update!(starts_at: Time.zone.today - 3.years - 1.day)

    DisputeStatusUpdateJob.run
    dispute.reload

    assert dispute.closed

    whois_record = Whois::Record.find_by(name: dispute.domain_name)
    assert_equal ['AtAuction'], whois_record.json['status']
  end

  def test_registered_domain_whois_data_is_added
    Dispute.create(domain_name: 'shop.test', starts_at: '2010-07-05')
    travel_to Time.zone.parse('2010-07-05')
    DisputeStatusUpdateJob.run

    whois_record = Whois::Record.find_by(name: 'shop.test')
    assert_includes whois_record.json['status'], 'disputed'
  end

  def test_registered_domain_whois_data_is_removed
    travel_to Time.zone.parse('2010-07-05')

    domain = domains(:shop)
    domain.update(valid_to: Time.zone.parse('2015-07-05').to_s(:db),
                  outzone_at: Time.zone.parse('2015-07-06').to_s(:db),
                  delete_date: nil,
                  force_delete_date: nil)

    # Dispute status is added automatically if starts_at is not in future
    Dispute.create(domain_name: 'shop.test', starts_at: Time.zone.parse('2010-07-05'))
    domain.reload

    whois_record = Whois::Record.find_by(name: 'shop.test')
    assert_includes whois_record.json['status'], 'disputed'

    # Dispute status is removed night time day after it's ended
    travel_to Time.zone.parse('2010-07-05') + 3.years + 1.day

    DisputeStatusUpdateJob.run

    whois_record.reload
    assert_not whois_record.json['status'].include? 'disputed'
  end
end
