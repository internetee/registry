require "test_helper"

class DomainUpdateConfirmJobTest < ActiveSupport::TestCase
  def setup
    super

    @domain = domains(:shop)
    @new_registrant = contacts(:william)
    @user = users(:api_bestnames)

    @domain.update!(pending_json: { new_registrant_id: @new_registrant.id,
                                    new_registrant_name: @new_registrant.name,
                                    new_registrant_email: @new_registrant.email,
                                    current_user_id: @user.id })
  end

  def teardown
    super
  end

  def test_rejected_registrant_verification_polls_a_message
    DomainUpdateConfirmJob.enqueue(@domain.id, RegistrantVerification::REJECTED)

    last_registrar_message = @domain.registrar.messages.last
    assert_equal(last_registrar_message.attached_obj_id, @domain.id)
    assert_equal(last_registrar_message.body, 'Registrant rejected domain update: shop.test')
  end

  def test_accepted_registrant_verification_polls_a_message
    DomainUpdateConfirmJob.enqueue(@domain.id, RegistrantVerification::CONFIRMED)

    last_registrar_message = @domain.registrar.messages.last
    assert_equal(last_registrar_message.attached_obj_id, @domain.id)
    assert_equal(last_registrar_message.body, 'Registrant confirmed domain update: shop.test')
  end
end
