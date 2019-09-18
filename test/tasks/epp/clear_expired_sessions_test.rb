require 'test_helper'

class EppClearExpiredSessionsTaskTest < ActiveSupport::TestCase
  setup do
    @original_session_timeout = EppSession.timeout
  end

  teardown do
    EppSession.timeout = @original_session_timeout
  end

  def test_clears_expired_epp_sessions
    timeout = 0.second
    EppSession.timeout = timeout
    session = epp_sessions(:api_bestnames)
    session.update!(updated_at: Time.zone.now - timeout - 1.second)

    run_task

    assert_nil EppSession.find_by(session_id: session.session_id)
  end

  private

  def run_task
    Rake::Task['epp:clear_expired_sessions'].execute
  end
end
