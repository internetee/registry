require 'test_helper'

class DomainTransferTest < ActiveSupport::TestCase
  setup do
    @domain_transfer = domain_transfers(:shop)
  end

  def test_approval
    @domain_transfer.approve
    @domain_transfer.reload
    assert @domain_transfer.approved?
  end

  def test_notifies_old_registrar_on_approval
    old_registrar = @domain_transfer.old_registrar

    assert_difference -> { old_registrar.notifications.count } do
      @domain_transfer.approve
    end

    body = 'Transfer of domain shop.test has been approved.' \
      ' It was associated with registrant john-001' \
      ' and contacts acme-ltd-001, jane-001, william-001.'
    id = @domain_transfer.id
    class_name = @domain_transfer.class.name

    notification = old_registrar.notifications.last
    assert_equal body, notification.body
    assert_equal id, notification.attached_obj_id
    assert_equal class_name, notification.attached_obj_type
  end
end
