require 'test_helper'

class DomainTransferTest < ActiveSupport::TestCase
  def setup
    @domain_transfer = domain_transfers(:shop)
  end

  def test_approval
    @domain_transfer.approve
    @domain_transfer.reload
    assert @domain_transfer.approved?
  end

  def test_notifies_old_registrar_on_approval
    old_registrar = @domain_transfer.old_registrar

    assert_difference -> { old_registrar.messages.count } do
      @domain_transfer.approve
    end

    body = 'Transfer of domain shop.test has been approved.' \
      ' It was associated with registrant john-001' \
      ' and contacts jane-001, william-001.'
    id = @domain_transfer.id
    class_name = @domain_transfer.class.name

    message = old_registrar.messages.last
    assert_equal body, message.body
    assert_equal id, message.attached_obj_id
    assert_equal class_name, message.attached_obj_type
  end
end
