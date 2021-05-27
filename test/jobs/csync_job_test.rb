require 'test_helper'

class CsyncJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @dnskey = dnskeys(:one)
    @domain = domains(:shop)
    dirname = File.dirname(ENV['cdns_scanner_input_file'])

    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    FileUtils.touch(ENV['cdns_scanner_input_file']) unless File.exists?(ENV['cdns_scanner_input_file'])
  end

  def test_generates_input_file_for_cdnskey_scanner
    @dnskey.update(domain: domains(:shop))

    expected_contents = "[secure]\nns1.bestnames.test shop.test\nns2.bestnames.test shop.test\n" \
    "[insecure]\nns1.bestnames.test airport.test metro.test\nns2.bestnames.test airport.test\n"

    CsyncJob.perform_now(generate: true)

    assert_equal expected_contents, IO.read(ENV['cdns_scanner_input_file'])
  end

  def test_generates_input_file_from_name_puny
    @domain.update(name: 'pööriöö.ee', name_puny: 'xn--pri-snaaca.ee')
    @domain.save(validate: false)
    @nameserver = @domain.nameservers.first
    @nameserver.update(hostname: 'täpiline.ee', hostname_puny: 'xn--theke1-bua.ee')
    @domain.reload
    @dnskey.update(domain: @domain)

    expected_contents = "[secure]\nns2.bestnames.test #{@domain.name_puny}\n#{@nameserver.hostname_puny} #{@domain.name_puny}\n" \
    "[insecure]\nns2.bestnames.test airport.test\nns1.bestnames.test airport.test metro.test\n"

    CsyncJob.perform_now(generate: true)
    assert_equal expected_contents, IO.read(ENV['cdns_scanner_input_file'])
  end

  def test_creates_csync_record_when_new_cdnskey_discovered
    assert_nil @domain.csync_record
    CsyncJob.perform_now

    @domain.reload
    assert @domain.csync_record
    csync_record = @domain.csync_record
    assert_equal 1, csync_record.times_scanned
    assert_equal '257 3 13 mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ==', csync_record.cdnskey

    assert_not @domain.dnskeys.any?
  end

  def test_creates_dnskey_after_required_cycles
    assert_equal 0, @domain.dnskeys.count
    assert_nil @domain.csync_record
    CsyncJob.perform_now # Creates initial CsyncRecord for domain

    @domain.reload
    assert @domain.csync_record.present?

    @domain.csync_record.update(times_scanned: 2) # 3rd time trigger DNSKEY push
    assert_equal 0, @domain.dnskeys.count
    assert_equal 2, @domain.csync_record.times_scanned

    CsyncRecord.stub :by_domain_name, @domain.csync_record do
      @domain.csync_record.stub :dnssec_validates?, true do
        CsyncJob.perform_now
      end
    end

    @domain.reload
    assert_equal 1, @domain.dnskeys.count
    assert_equal 'mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ==', @domain.dnskeys.last.public_key
    assert_nil @domain.csync_record
  end

  def test_sends_mail_to_contacts_if_dnskey_updated
    assert_emails 1 do
      CsyncJob.perform_now
      @domain.reload

      CsyncRecord.stub :by_domain_name, @domain.csync_record do
        @domain.csync_record.stub :dnssec_validates?, true do
          2.times do
            CsyncJob.perform_now
          end
        end
      end
    end
  end
end
