require 'test_helper'

class ReleaseDomainsTaskTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_output
    @domain.update!(delete_at: Time.zone.parse('2010-07-05 07:59'))
    travel_to Time.zone.parse('2010-07-05 08:00')
    assert_output("shop.test is released\nReleased total: 1\n") { run_task }
  end

  private

  def run_task
    Rake::Task['domains:release'].execute
  end
end
