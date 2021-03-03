require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  def test_env_style_when_pic_present
    assert_dom_equal %{<body style={"background-image: url(#{image_path("registrar/bg-#{unstable_env}.png")});"}>},
            %{<body style={"#{env_style}"}>}
  end

  def test_env_style_return_nil
    env_style = ''
    assert_dom_equal %{<body style=''>},
            %{<body style={"#{env_style}"}>}
  end
end
