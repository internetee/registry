require 'test_helper'

class DeathRegistry::FileBuilderTest < ActiveSupport::TestCase
  HISTORY_URL = 'https://opendata.test/surmaandmed_ajalugu.csv'.freeze
  CURRENT_URL = 'https://opendata.test/surmaandmed_jooksev_aasta.csv'.freeze
  HEADER = "﻿eesnimi;perenimi;isikukood;synni_kp;surma_kp\n".freeze

  setup do
    @dir = Dir.mktmpdir
    @path = File.join(@dir, 'deaths.txt')
  end

  teardown do
    FileUtils.rm_rf(@dir)
  end

  def test_writes_sorted_fixed_width_records_from_all_sources
    stub_csv(HISTORY_URL, <<~CSV)
      "MARI";"MAASIKAS";"48001010001";"1980-01-01";"2020-05-06"
      "JAAN";"TAMM";"37001010002";"1970-01-01";"2019-03-04"
    CSV
    stub_csv(CURRENT_URL, <<~CSV)
      "PEETER";"KASK";"39001010003";"1990-01-01";"2026-02-03"
    CSV

    assert_equal 3, build

    assert_equal "37001010002;2019-03-04\n" \
                 "39001010003;2026-02-03\n" \
                 "48001010001;2020-05-06\n", File.read(@path)
  end

  def test_skips_rows_without_valid_ident_or_death_date
    stub_csv(HISTORY_URL, <<~CSV)
      "MARI";"MAASIKAS";-;"1880-01-01";"1930-05-06"
      "JAAN";"TAMM";"370010100";"1970-01-01";"2019-03-04"
      "ANU";"SAAR";"47001010004";"1970-01-01";-
      "PEETER";"KASK";"39001010003";"1990-01-01";"2026-02-03"
    CSV
    stub_csv(CURRENT_URL, '')

    assert_equal 1, build
    assert_equal "39001010003;2026-02-03\n", File.read(@path)
  end

  def test_keeps_earliest_death_date_of_duplicated_ident
    stub_csv(HISTORY_URL, <<~CSV)
      "JAAN";"TAMM";"37001010002";"1970-01-01";"2019-03-04"
    CSV
    stub_csv(CURRENT_URL, <<~CSV)
      "JAAN";"TAMM";"37001010002";"1970-01-01";"2018-01-01"
    CSV

    assert_equal 1, build
    assert_equal "37001010002;2018-01-01\n", File.read(@path)
  end

  def test_keeps_old_file_when_download_fails
    File.write(@path, "37001010002;2019-03-04\n")
    stub_csv(HISTORY_URL, %("JAAN";"TAMM";"39001010003";"1990-01-01";"2026-02-03"\n))
    stub_request(:get, CURRENT_URL).to_return(status: 503)

    error = assert_raises(DeathRegistry::Error) { build }

    assert_includes error.message, 'HTTP 503'
    assert_equal "37001010002;2019-03-04\n", File.read(@path)
  end

  def test_keeps_old_file_when_too_few_records
    File.write(@path, "37001010002;2019-03-04\n")
    stub_csv(HISTORY_URL, %("JAAN";"TAMM";"39001010003";"1990-01-01";"2026-02-03"\n))
    stub_csv(CURRENT_URL, '')

    error = assert_raises(DeathRegistry::Error) { build(min_records: 2) }

    assert_includes error.message, 'only 1 records'
    assert_equal "37001010002;2019-03-04\n", File.read(@path)
    assert_equal ['deaths.txt'], Dir.children(@dir)
  end

  def test_fails_when_csv_format_changes
    stub_request(:get, HISTORY_URL).to_return(status: 200, body: "nimi,kood\nJAAN,37001010002\n")
    stub_csv(CURRENT_URL, '')

    assert_raises(DeathRegistry::Error) { build }
    assert_not File.exist?(@path)
  end

  def test_built_file_works_with_lookup
    stub_csv(HISTORY_URL, <<~CSV)
      "MARI";"MAASIKAS";"48001010001";"1980-01-01";"2020-05-06"
      "JAAN";"TAMM";"37001010002";"1970-01-01";"2019-03-04"
    CSV
    stub_csv(CURRENT_URL, '')
    build

    lookup = DeathRegistry::Lookup.new(path: @path)

    assert_equal Date.new(2020, 5, 6), lookup.death_date('48001010001')
    assert_nil lookup.death_date('38001010009')
  end

  private

  def build(min_records: 1)
    DeathRegistry::FileBuilder.new(path: @path,
                                   source_urls: [HISTORY_URL, CURRENT_URL],
                                   min_records: min_records).call
  end

  def stub_csv(url, rows)
    stub_request(:get, url).to_return(status: 200, body: HEADER + rows)
  end
end
