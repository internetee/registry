require 'test_helper'

class EppClearExpiredSessionsTaskTest < ActiveSupport::TestCase
  setup do
    @original_session_timeout = EppSession.timeout
  end

  teardown do
    EppSession.timeout = @original_session_timeout
  end

  def test_clears_expired_epp_sessions
    timeout = EppSession.timeout
    session = epp_sessions(:api_bestnames)
    next_session = epp_sessions(:api_goodnames)
    session.update!(updated_at: Time.zone.now - timeout - 1.second)

    run_task

    assert_nil EppSession.find_by(session_id: session.session_id)
    assert EppSession.find_by(session_id: next_session.session_id)
  end

  private

  def run_task
    Rake::Task['epp:clear_expired_sessions'].execute
  end
end
