require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  def test_creator_link
    model = contacts(:william)
    assert_nothing_raised do
      ApplicationController.helpers.creator_link(model)
    end

    assert_nothing_raised do
      ApplicationController.helpers.updator_link(model)
    end
  end
end
