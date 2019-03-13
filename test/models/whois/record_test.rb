require 'test_helper'

class Whois::RecordTest < ActiveSupport::TestCase
  fixtures 'whois/records'

  setup do
    @original_disclaimer_setting = Setting.registry_whois_disclaimer
  end

  teardown do
    Setting.registry_whois_disclaimer = @original_disclaimer_setting
  end

  def test_reads_disclaimer_from_settings
    Setting.registry_whois_disclaimer = 'test disclaimer'
    assert_equal 'test disclaimer', Whois::Record.disclaimer
  end

  def test_creates_new_whois_record_when_domain_is_at_auction
    domain_name = DNS::DomainName.new('some.test')
    Setting.registry_whois_disclaimer = 'disclaimer'

    domain_name.stub(:at_auction?, true) do
      assert_difference 'Whois::Record.count' do
        Whois::Record.refresh(domain_name)
      end
    end

    whois_record = Whois::Record.last
    assert_equal 'some.test', whois_record.name
    assert_equal ({ 'name' => 'some.test',
                    'status' => ['AtAuction'],
                    'disclaimer' => 'disclaimer' }), whois_record.json
  end

  def test_refreshes_whois_record_when_domain_auction_reaches_awaiting_payment_state
    domain_name = DNS::DomainName.new('some.test')
    Setting.registry_whois_disclaimer = 'disclaimer'
    whois_records(:one).update!(name: 'some.test')

    domain_name.stub(:awaiting_payment?, true) do
      Whois::Record.refresh(domain_name)
    end

    whois_record = Whois::Record.find_by(name: 'some.test')
    assert_equal 'some.test', whois_record.name
    assert_equal ({ 'name' => 'some.test',
                    'status' => ['PendingRegistration'],
                    'disclaimer' => 'disclaimer' }), whois_record.json
  end

  def test_refreshes_whois_record_when_domain_auction_reaches_pending_registration_state
    domain_name = DNS::DomainName.new('some.test')
    Setting.registry_whois_disclaimer = 'disclaimer'
    whois_records(:one).update!(name: 'some.test')

    domain_name.stub(:pending_registration?, true) do
      Whois::Record.refresh(domain_name)
    end

    whois_record = Whois::Record.find_by(name: 'some.test')
    assert_equal 'some.test', whois_record.name
    assert_equal ({ 'name' => 'some.test',
                    'status' => ['PendingRegistration'],
                    'disclaimer' => 'disclaimer' }), whois_record.json
  end
end
