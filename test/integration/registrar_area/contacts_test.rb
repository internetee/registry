require 'test_helper'

class RegistrarAreaContactsIntegrationTest < ApplicationIntegrationTest
  setup do
    sign_in users(:api_bestnames)
  end

  def test_downloads_list_as_csv
    get registrar_contacts_path(format: :csv)

    assert_response :ok
    assert_equal "#{Mime[:csv]}; charset=utf-8", response.headers['Content-Type']
    assert_equal 'attachment; filename="contacts.csv"', response.headers['Content-Disposition']
    assert_not_empty response.body
  end

  def test_downloads_list_as_pdf
    get registrar_contacts_path(format: :pdf)

    assert_response :ok
    assert_equal Mime[:pdf], response.headers['Content-Type']
    assert_equal 'attachment; filename="contacts.pdf"', response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end
