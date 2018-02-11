require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    @message = messages(:greeting)
  end

  def test_valid
    assert @message.valid?
  end

  def test_invalid_without_body
    @message.body = nil
    @message.validate
    assert @message.invalid?
  end
end
