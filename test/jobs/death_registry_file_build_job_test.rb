require 'test_helper'

class DeathRegistryFileBuildJobTest < ActiveJob::TestCase
  setup do
    @dir = Dir.mktmpdir
    @path = File.join(@dir, 'deaths.txt')
    @url = 'https://opendata.test/surmaandmed.csv'
    ENV['death_registry_file_path'] = @path
    ENV['death_registry_source_urls'] = @url
    ENV['death_registry_min_records'] = '1'
  end

  teardown do
    ENV.delete('death_registry_file_path')
    ENV.delete('death_registry_source_urls')
    ENV.delete('death_registry_min_records')
    FileUtils.rm_rf(@dir)
  end

  def test_builds_file_from_configured_sources
    stub_request(:get, @url).to_return(status: 200, body: <<~CSV)
      ﻿eesnimi;perenimi;isikukood;synni_kp;surma_kp
      "JAAN";"TAMM";"37001010002";"1970-01-01";"2019-03-04"
    CSV

    DeathRegistryFileBuildJob.perform_now

    assert_equal "37001010002;2019-03-04\n", File.read(@path)
  end
end
