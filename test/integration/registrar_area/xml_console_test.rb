require 'test_helper'

class RegistrarAreaDomainsIntegrationTest < ApplicationIntegrationTest
  setup do
    sign_in users(:api_bestnames)
  end

  def test_show_xml_console
    visit registrar_xml_console_path
    assert_text 'XML Console'
  end

end