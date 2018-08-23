require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  setup do
    @notification = notifications(:greeting)
  end

  def test_valid
    assert @notification.valid?
  end

  def test_invalid_without_text
    @notification.text = ''
    assert @notification.invalid?
  end

  def test_invalid_without_registrar
    @notification.registrar = nil
    assert @notification.invalid?
  end

  def test_dequeue
    @notification.dequeue
    @notification.reload
    assert_not @notification.queued?
  end
end