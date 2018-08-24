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

  def test_unread_by_default
    notification = Notification.new(registrar: registrars(:bestnames), text: 'test')
    assert_not notification.read?

    notification.save!
    assert_not notification.read?
  end

  def test_honor_given_read_state
    notification = Notification.new(read: true)
    assert notification.read?
  end

  def test_mark_as_read
    @notification.mark_as_read
    @notification.reload
    assert @notification.read?
  end
end