require 'test_helper'

class AdminDomainsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess

  setup do
    @admin = users(:admin)
    sign_in @admin

    @domain = domains(:shop)
  end

  def test_index_renders_successfully
    get admin_domains_path
    assert_response :success
    assert_match @domain.name, response.body
  end

  def test_index_with_status_filter
    status = @domain.statuses.first || 'client_hold'
    get admin_domains_path, params: { statuses_contains: [status] }
    assert_response :success
  end

  def test_update_statuses_success
    Domain.stub_any_instance(:admin_status_update, true) do
      Domain.stub_any_instance(:update, true) do
        patch admin_domain_path(@domain),
              params: { domain: { statuses: ['client_hold', ''] } },
              headers: { 'HTTP_REFERER' => admin_domain_path(@domain) }
      end
    end

    assert_redirected_to admin_domain_path(@domain)
    assert_equal I18n.t('domain_updated'), flash[:notice]
  end

  def test_update_statuses_failure
    Domain.stub_any_instance(:admin_status_update, false) do
        Domain.stub_any_instance(:update, false) do
            patch admin_domain_path(@domain),
                params: { domain: { statuses: ['client_hold', ''] } },
                headers: { 'HTTP_REFERER' => admin_domain_path(@domain) }
        end
    end

    assert_response :success
    assert_match I18n.t('failed_to_update_domain'), flash[:alert]
  end

  def test_versions_page_success
    get admin_domain_domain_versions_path(@domain)
    assert_response :success
    assert_match @domain.name, response.body
  end

  def test_keep_domain
    Domain.stub_any_instance(:keep, true) do
      patch keep_admin_domain_path(@domain)
    end

    assert_redirected_to edit_admin_domain_url(@domain)
    assert flash[:notice].present?
  end
end 