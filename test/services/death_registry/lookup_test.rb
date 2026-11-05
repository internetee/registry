require 'test_helper'

class DeathRegistry::LookupTest < ActiveSupport::TestCase
  RECORDS = {
    '33109066015' => '2026-01-01',
    '35809012714' => '2025-12-31',
    '37509205215' => '2024-06-15',
    '43812063712' => '2019-03-04',
    '60001019906' => '2001-02-03',
  }.freeze

  setup do
    @dir = Dir.mktmpdir
    @path = File.join(@dir, 'deaths.txt')
    File.write(@path, RECORDS.map { |ident, date| "#{ident};#{date}\n" }.join)
    @lookup = DeathRegistry::Lookup.new(path: @path, max_age: 8.days)
  end

  teardown do
    FileUtils.rm_rf(@dir)
  end

  def test_finds_every_record
    RECORDS.each do |ident, date|
      assert_equal Date.iso8601(date), @lookup.death_date(ident), ident
    end
  end

  def test_returns_nil_for_ident_not_in_file
    assert_nil @lookup.death_date('30001010000')
    assert_nil @lookup.death_date('38001010000')
    assert_nil @lookup.death_date('69912319999')
    assert_not @lookup.deceased?('38001010000')
  end

  def test_returns_nil_for_invalid_ident
    assert_nil @lookup.death_date('3750920521')
    assert_nil @lookup.death_date('375092052150')
    assert_nil @lookup.death_date(nil)
  end

  def test_deceased
    assert @lookup.deceased?('37509205215')
  end

  def test_raises_when_file_is_missing
    File.delete(@path)

    assert_not @lookup.available?
    assert_raises(DeathRegistry::FileUnavailable) { @lookup.death_date('37509205215') }
  end

  def test_raises_when_file_is_stale
    File.utime(9.days.ago.to_time, 9.days.ago.to_time, @path)

    assert_not @lookup.available?
    assert_raises(DeathRegistry::FileUnavailable) { @lookup.death_date('37509205215') }
  end

  def test_raises_when_file_is_malformed
    File.write(@path, "37509205215;2024-06-15\npartial")

    assert_not @lookup.available?
    assert_raises(DeathRegistry::FileUnavailable) { @lookup.death_date('37509205215') }
  end

  def test_empty_file_finds_nothing
    File.write(@path, '')

    assert_nil @lookup.death_date('37509205215')
  end
end
