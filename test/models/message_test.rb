require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  setup do
    @message = messages(:greeting)
  end

  def test_valid
    assert @message.valid?
  end

  def test_invalid_without_body
    @message.body = nil
    assert @message.invalid?
  end

  def test_invalid_without_registrar
    @message.registrar = nil
    assert @message.invalid?
  end
end
