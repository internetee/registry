require 'test_helper'

class RegistrantAreaDomainsIntegrationTest < ApplicationIntegrationTest
  setup do
    sign_in users(:registrant)
  end

  def test_downloads_list_as_csv
    get registrant_domains_path(format: :csv)

    assert_response :ok
    assert_equal "#{Mime[:csv]}; charset=utf-8", response.headers['Content-Type']
    assert_equal "attachment; filename=\"domains.csv\"; filename*=UTF-8''domains.csv", response.headers['Content-Disposition']
    assert_not_empty response.body
  end

  def test_downloads_list_as_pdf
    get registrant_domains_path(format: :pdf)

    assert_response :ok
    assert_equal Mime[:pdf], response.headers['Content-Type']
    assert_equal "attachment; filename=\"domains.pdf\"; filename*=UTF-8''domains.pdf", response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end
