require 'test_helper'

class RegistrarAreaDomainsIntegrationTest < ApplicationIntegrationTest
  setup do
    sign_in users(:api_bestnames)
  end

  def test_downloads_list_as_csv
    now = Time.zone.parse('2010-07-05 08:00')
    travel_to now

    get registrar_domains_path(format: :csv)

    assert_response :ok
    assert_equal "#{Mime[:csv]}; charset=utf-8", response.headers['Content-Type']
    assert_equal %(attachment; filename="Domains_#{l(now, format: :filename)}.csv"),
                 response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end
