require 'test_helper'

class ScanCsvRegistryBusinnesContactsJobTest < ActiveJob::TestCase
  def test_delivers_email
    filename = 'test/fixtures/files/ette.csv'

    assert_performed_jobs 1 do
      ScanCsvRegistryBusinnesContactsJob.perform_later(filename)
    end
  end
end
