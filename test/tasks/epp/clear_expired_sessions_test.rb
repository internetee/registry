require 'test_helper'

class EppClearExpiredSessionsTaskTest < ActiveSupport::TestCase
  def test_clears_expired_epp_sessions
    idle_timeout = 0.second
    EppSession.idle_timeout = idle_timeout
    session = epp_sessions(:api_bestnames)
    session.update!(updated_at: Time.zone.now - idle_timeout - 1.second)

    run_task

    assert_nil EppSession.find_by(session_id: session.session_id)
  end

  private

  def run_task
    Rake::Task['epp:clear_expired_sessions'].execute
  end
end
