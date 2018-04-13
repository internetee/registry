require 'test_helper'

class AdminAreaNewMailTemplateTest < ActionDispatch::IntegrationTest
  setup do
    login_as users(:admin)
  end

  def test_new_mail_template_does_not_throw_template_error
    visit admin_mail_templates_url
    click_link_or_button 'New'
    assert_text "HTML body"
    assert_text "New mail template"
  end
end
