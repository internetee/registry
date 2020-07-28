require 'test_helper'

class CsyncRecordTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)

    @csync_record = CsyncRecord.new
    @csync_record.cdnskey = '257 3 13 mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ=='
    @csync_record.action = 'initialized'
    @csync_record.domain = domains(:shop)
    @csync_record.last_scan = Time.now
  end

  def test_domain_must_be_present
    @csync_record.domain = nil
    assert_not @csync_record.valid?
    @csync_record.domain = domains(:shop)
  end

  def test_action_must_be_present_and_valid
    @csync_record.action = nil
    assert_not @csync_record.valid?

    @csync_record.action = 'what the fuck'
    assert_not @csync_record.valid?

    @csync_record.action = 'initialized'
    assert @csync_record.valid?

    @csync_record.action = 'rollover'
    assert @csync_record.valid?

    @csync_record.action = 'deactivate'
    assert_not @csync_record.valid?

    @csync_record.action = 'deactivate'
    @csync_record.cdnskey = '0 3 0 AA=='
    assert @csync_record.valid?
  end

  def test_cdnskey_must_be_unique_for_domain
    dnskey = @csync_record.dnskey
    dnskey.save!

    assert_not @csync_record.valid?
    assert_includes @csync_record.errors.full_messages, 'Public key already tied to this domain'

    @csync_record.cdnskey = nil
    assert_not @csync_record.valid?
    assert_includes @csync_record.errors.full_messages, 'Cdnskey is missing'
  end

  def test_cdnskey_must_be_parsable
    @csync_record.cdnskey = 'gibberish'
    assert_not @csync_record.valid?

    @csync_record.cdnskey = nil
    assert_not @csync_record.valid?
    @csync_record.cdnskey = ''
    assert_not @csync_record.valid?

    @csync_record.cdnskey = '257 3 13 KlHFYV42UtxC7LpsolDpoUZ9DNPDRYQypalBRIqlubBg/zg78aqciLk+NaWUbrkN7AUaM7h7tx91sLN+ORVPxA=='
    assert @csync_record.valid?
  end

  def test_initializes_valid_record_with_scanner_input
    scanner_result = {
      type: 'insecure', ns: 'ns1.bestnames.test', ns_ip: '127.0.0.1', flags: '257', proto: '3', alg: '13',
      pub: 'mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ==',
      cdnskey: '257 3 13 mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ=='
    }

    csync_record = CsyncRecord.by_domain_name(@domain.name)
    csync_record.assign_scanner_data!(scanner_result)

    assert csync_record.valid?
    assert_equal scanner_result[:cdnskey], csync_record.cdnskey
    assert_equal 'initialized', csync_record.action
    assert_equal 1, csync_record.times_scanned
  end

  def test_creates_rollover_record_with_scanner_input
    # Rollover always requires valid dnssec conf beforehand
    dnskey = @csync_record.dnskey
    dnskey.save!

    # Type 'secure' reflects from cdnskey-scanner that custom domain security level is SECURE (dnssec valid)
    scanner_result = {
      type: 'secure', ns: 'ns1.bestnames.test', ns_ip: '127.0.0.1', flags: '256', proto: '3', alg: '13',
      pub: 'PiVTNvqOTrCSoXf5obNEPrDe0yhrKPmjyv+MWfoscBHF49rRIH1/yDdAXY3SyUD86qq/AiXDzsTQIqOjvak7gw==',
      cdnskey: '256 3 13 PiVTNvqOTrCSoXf5obNEPrDe0yhrKPmjyv+MWfoscBHF49rRIH1/yDdAXY3SyUD86qq/AiXDzsTQIqOjvak7gw=='
    }

    csync_record = CsyncRecord.by_domain_name(@domain.name)
    csync_record.assign_scanner_data!(scanner_result)
    assert_equal 'rollover', csync_record.action
    assert csync_record.valid?

    scanner_result[:type] = 'insecure'
    csync_record.assign_scanner_data!(scanner_result)
    assert_not csync_record.valid?
    assert_includes csync_record.errors.full_messages, 'Action is invalid'
  end

  def test_creates_deactivate_record_with_scanner_input
    # Deactivate always requires valid dnssec conf beforehand
    dnskey = @csync_record.dnskey
    dnskey.save!

    # Type 'secure' reflects from cdnskey-scanner that custom domain security level is SECURE (dnssec valid)
    scanner_result = {
      type: 'secure', ns: 'ns1.bestnames.test', ns_ip: '127.0.0.1', flags: '0', proto: '3', alg: '0',
      pub: 'AA==',
      cdnskey: '0 3 0 AA=='
    }

    csync_record = CsyncRecord.by_domain_name(@domain.name)
    csync_record.assign_scanner_data!(scanner_result)
    assert_equal 'deactivate', csync_record.action
    assert csync_record.valid?

    scanner_result[:type] = 'insecure'
    csync_record.assign_scanner_data!(scanner_result)
    assert_not csync_record.valid?
    assert_includes csync_record.errors.full_messages, 'Action is invalid'
  end

  def test_initializes_dnssec_for_domain
    scanner_result = {
      type: 'insecure', ns: 'ns1.bestnames.test', ns_ip: '127.0.0.1', flags: '257', proto: '3', alg: '13',
      pub: 'mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ==',
      cdnskey: '257 3 13 mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ=='
    }

    2.times { CsyncRecord.by_domain_name(@domain.name).record_new_scan(scanner_result) }
    @domain.reload

    CsyncRecord.stub :by_domain_name, @domain.csync_record do
      @domain.csync_record.stub :dnssec_validates?, true do
        CsyncRecord.by_domain_name(@domain.name).record_new_scan(scanner_result)
      end
    end

    assert_equal 1, @domain.dnskeys.count
    assert_equal scanner_result[:pub], @domain.dnskeys.last.public_key

    mail = ActionMailer::Base.deliveries.last
    assert_equal (@domain.contacts.map(&:email) << @domain.registrant.email).uniq, mail.to
    assert_equal mail.subject, "Teie domeeni #{@domain.name} DNSSEC andmed on uuendatud / DNSSEC data for #{@domain.name} has been updated"
  end

  def test_rollovers_dnssec_for_domain
    dnskey = @csync_record.dnskey
    dnskey.save!

    scanner_result = {
      type: 'secure', ns: 'ns1.bestnames.test', ns_ip: '127.0.0.1', flags: '256', proto: '3', alg: '13',
      pub: 'PiVTNvqOTrCSoXf5obNEPrDe0yhrKPmjyv+MWfoscBHF49rRIH1/yDdAXY3SyUD86qq/AiXDzsTQIqOjvak7gw==',
      cdnskey: '256 3 13 PiVTNvqOTrCSoXf5obNEPrDe0yhrKPmjyv+MWfoscBHF49rRIH1/yDdAXY3SyUD86qq/AiXDzsTQIqOjvak7gw=='
    }

    stub_any_instance(CsyncRecord, :dnssec_validates?, true) do
      CsyncRecord.by_domain_name(@domain.name).record_new_scan(scanner_result)
    end

    assert_equal 2, @domain.dnskeys.count
    assert_equal scanner_result[:pub], @domain.dnskeys.last.public_key

    mail = ActionMailer::Base.deliveries.last
    assert_equal (@domain.contacts.map(&:email) << @domain.registrant.email).uniq, mail.to
    assert_equal mail.subject, "Teie domeeni #{@domain.name} DNSSEC andmed on uuendatud / DNSSEC data for #{@domain.name} has been updated"
  end

  def test_deactivates_dnssec_for_domain
    dnskey = @csync_record.dnskey
    dnskey.save!

    scanner_result = {
      type: 'secure', ns: 'ns1.bestnames.test', ns_ip: '127.0.0.1', flags: '0', proto: '3', alg: '0',
      pub: 'AA==',
      cdnskey: '0 3 0 AA=='
    }

    stub_any_instance(CsyncRecord, :dnssec_validates?, true) do
      CsyncRecord.by_domain_name(@domain.name).record_new_scan(scanner_result)
    end

    assert @domain.dnskeys.empty?

    mail = ActionMailer::Base.deliveries.last
    assert_equal (@domain.contacts.map(&:email) << @domain.registrant.email).uniq, mail.to
    assert_equal mail.subject, "Teie domeeni #{@domain.name} DNSSEC andmed on eemaldatud / DNSSEC data for #{@domain.name} has been removed"
  end

  def stub_any_instance(klass, method, value)
    klass.class_eval do
      alias_method :"new_#{method}", method

      define_method(method) do
        if value.respond_to?(:call)
          value.call
        else
          value
        end
      end
    end

    yield
  ensure
    klass.class_eval do
      undef_method method
      alias_method method, :"new_#{method}"
      undef_method :"new_#{method}"
    end
  end
end
