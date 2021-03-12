require "test_helper"

class RegenerateRegistrarWhoisesJobTest < ActiveSupport::TestCase
  setup do
    travel_to Time.zone.parse('2010-07-05 10:00')
    @registrar = registrars(:bestnames)
  end

  def test_job_return_true
    # if return false, then job was failes
    assert RegenerateRegistrarWhoisesJob.run(@registrar.id)
  end
end