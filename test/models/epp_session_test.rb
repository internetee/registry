require 'test_helper'

class EppSessionTest < ActiveSupport::TestCase
  def setup
    @epp_session = epp_sessions(:api_bestnames)
  end

  def test_valid
    assert @epp_session.valid?
  end

  def test_invalid_without_session_id
    @epp_session.session_id = nil
    @epp_session.validate
    assert @epp_session.invalid?
  end

  def test_invalid_without_user
    @epp_session.user = nil
    @epp_session.validate
    assert @epp_session.invalid?
  end

  def test_invalid_if_persisted_record_with_the_same_session_id_exists
    epp_session = EppSession.new(session_id: @epp_session.session_id, user: @epp_session.user)
    epp_session.validate
    assert epp_session.invalid?
  end

  # Having session_id constraints at the database level is crucial

  def test_database_session_id_unique_constraint
    epp_session = EppSession.new(session_id: @epp_session.session_id, user: @epp_session.user)

    assert_raises ActiveRecord::RecordNotUnique do
      epp_session.save(validate: false)
    end
  end

  def test_database_session_id_not_null_constraint
    @epp_session.session_id = nil
    assert_raises ActiveRecord::StatementInvalid do
      @epp_session.save(validate: false)
    end
  end

  def test_limit_per_registrar
    assert_equal 4, EppSession.limit_per_registrar
  end

  def test_limit_is_per_registrar
    travel_to Time.zone.parse('2010-07-05')
    EppSession.delete_all

    EppSession.limit_per_registrar.times do
      EppSession.create!(session_id: SecureRandom.hex,
                         user: users(:api_goodnames),
                         updated_at: Time.zone.parse('2010-07-05'))
    end

    refute EppSession.limit_reached?(registrars(:bestnames))
  end
end
