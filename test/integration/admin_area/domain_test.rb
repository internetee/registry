require 'test_helper'

class DomainTest < ApplicationIntegrationTest
  setup do
    @domain = domains(:shop)
    sign_in users(:admin)
  end

  def test_downloads_domain
    filename = "#{@domain.name}.pdf"
    get download_admin_domain_path(@domain)

    assert_response :ok
    assert_equal 'application/pdf', response.headers['Content-Type']
    assert_equal "attachment; filename=\"#{filename}\"; filename*=UTF-8''#{filename}", response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end
