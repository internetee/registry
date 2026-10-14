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

  def test_registrar_options_are_sorted_by_name
    registrars(:bestnames).update_columns(name: 'Zulu Names')
    registrars(:goodnames).update_columns(name: 'Alpha Names')

    options = registrar_options
    names = options.map(&:first).reject(&:blank?)

    assert_equal names.sort, names
    assert_equal 'Alpha Names', names.first
    assert_equal registrars(:goodnames).id, options.find { |name, _id| name == 'Alpha Names' }.last
  end
end
