require 'test_helper'

class CsyncJobTest < ActiveSupport::TestCase
  setup do
    @dnskey = dnskeys(:one)
    @domain = domains(:shop)
  end

  def test_generates_input_file_for_cdnskey_scanner
    @dnskey.update(domain: domains(:shop))

    expected_contents = "[secure]\nns1.bestnames.test shop.test\nns2.bestnames.test shop.test\n" \
    "[insecure]\nns1.bestnames.test airport.test metro.test\nns2.bestnames.test airport.test\n"

    CsyncJob.run(generate: true)

    assert_equal expected_contents, IO.read(ENV['cdns_scanner_input_file'])
  end

  def test_creates_csync_record_when_new_cdnskey_discovered
    assert_nil @domain.csync_record
    CsyncJob.run

    @domain.reload
    assert @domain.csync_record
    csync_record = @domain.csync_record
    assert_equal 1, csync_record.times_scanned
    assert_equal '257 3 13 mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ==', csync_record.cdnskey

    assert_not @domain.dnskeys.any?
  end
end
