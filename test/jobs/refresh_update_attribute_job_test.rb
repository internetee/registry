require 'test_helper'

class RefreshUpdateAttributeJobTest < ActiveJob::TestCase
  def test_after_running_test_should_be_created_new_version_of_domain
    @domain = domains(:shop)

    assert_difference '@domain.versions.count' do
      RefreshUpdateAttributeJob.perform_now('Domain', @domain.id, @domain.updated_at)
    end
  end
end
