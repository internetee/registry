require 'test_helper'

class AdminAreaRdapPrivilegeGrantsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @grant = rdap_privilege_grants(:police_active)
    sign_in @admin
  end

  # --- AC1: list ---------------------------------------------------------------
  def test_index_lists_grants
    get admin_rdap_privilege_grants_path

    assert_response :success
    assert_select 'table'
    assert_match @grant.full_name, response.body
    assert_match @grant.organization, response.body
  end

  # --- AC2: create -------------------------------------------------------------
  def test_create_valid_grant
    assert_difference('RdapPrivilegeGrant.count', 1) do
      post admin_rdap_privilege_grants_path, params: { rdap_privilege_grant: valid_params }
    end

    grant = RdapPrivilegeGrant.order(:created_at).last
    assert_redirected_to admin_rdap_privilege_grant_path(grant)
    assert_equal 'New Grantee', grant.full_name
    assert_equal 'MoU-2026-777', grant.legal_basis_ref
  end

  def test_create_invalid_grant_creates_no_row
    assert_no_difference('RdapPrivilegeGrant.count') do
      post admin_rdap_privilege_grants_path,
           params: { rdap_privilege_grant: valid_params.merge(full_name: '') }
    end

    assert_response :success # form re-rendered with errors
  end

  # --- AC3: edit ---------------------------------------------------------------
  def test_update_valid_grant
    patch admin_rdap_privilege_grant_path(@grant),
          params: { rdap_privilege_grant: { organization: 'new-org' } }

    assert_redirected_to admin_rdap_privilege_grant_path(@grant)
    assert_equal 'new-org', @grant.reload.organization
  end

  def test_update_invalid_grant_persists_nothing
    patch admin_rdap_privilege_grant_path(@grant),
          params: { rdap_privilege_grant: { legal_basis_ref: '' } }

    assert_response :success
    assert_not_equal '', @grant.reload.legal_basis_ref
  end

  # --- AC4 / AC5: suspend and revoke via distinct member routes ----------------
  def test_suspend_is_a_distinct_action
    post suspend_admin_rdap_privilege_grant_path(@grant)

    assert_redirected_to admin_rdap_privilege_grant_path(@grant)
    assert_equal 'suspended', @grant.reload.status
  end

  def test_revoke_is_a_distinct_action
    post revoke_admin_rdap_privilege_grant_path(@grant)

    assert_redirected_to admin_rdap_privilege_grant_path(@grant)
    assert_equal 'revoked', @grant.reload.status
  end

  # --- AC8 / AC9 / AC10: fields round-trip and render on show ------------------
  def test_show_renders_legal_basis_notes_and_full_name
    @grant.update!(notes: 'Investigation 2026-42', legal_basis_ref: 'MoU-show-1')

    get admin_rdap_privilege_grant_path(@grant)

    assert_response :success
    assert_match @grant.full_name, response.body
    assert_match 'MoU-show-1', response.body
    assert_match 'Investigation 2026-42', response.body
  end

  # --- AC11 / AC16: attribution + audit log on create and update ---------------
  def test_create_and_update_are_attributed_and_audited
    post admin_rdap_privilege_grants_path, params: { rdap_privilege_grant: valid_params }
    grant = RdapPrivilegeGrant.order(:created_at).last

    assert_equal @admin.id_role_username, grant.creator_str
    assert_equal @admin.id_role_username, grant.updator_str

    create_version = grant.versions.where(event: 'create').last
    assert_not_nil create_version
    assert_equal @admin.id_role_username, create_version.whodunnit

    patch admin_rdap_privilege_grant_path(grant),
          params: { rdap_privilege_grant: { organization: 'audited-org' } }

    update_version = grant.reload.versions.where(event: 'update').last
    assert_not_nil update_version
    assert_equal @admin.id_role_username, update_version.whodunnit
    assert_equal @admin.id_role_username, grant.updator_str
  end

  # --- AC17: audit history rendered on show ------------------------------------
  def test_show_renders_audit_history
    @grant.update!(organization: 'history-org')

    get admin_rdap_privilege_grant_path(@grant)

    assert_response :success
    assert_match I18n.t('admin.rdap_privilege_grants.show.audit_history'), response.body
    assert_match 'update', response.body
  end

  # --- AC18: no hard-delete route ----------------------------------------------
  def test_delete_is_not_routable
    assert_raises(ActionController::RoutingError) do
      delete admin_rdap_privilege_grant_path(@grant)
    end
  end

  # --- AC21: auth gating -------------------------------------------------------
  def test_unauthenticated_is_denied
    sign_out @admin
    get admin_rdap_privilege_grants_path

    assert_response :redirect
    assert_no_match(/rdap privilege grants/i, flash[:notice].to_s)
  end

  def test_non_admin_role_is_denied
    sign_out @admin
    sign_in non_admin_user
    get admin_rdap_privilege_grants_path

    assert_redirected_to root_url
  end

  def test_admin_role_is_allowed
    get admin_rdap_privilege_grants_path
    assert_response :success
  end

  # --- AC23: personal_id_code never leaks to the index -------------------------
  def test_personal_id_code_absent_from_index
    # Value chosen so it is NOT a substring of any rendered eeid_subject.
    @grant.update!(personal_id_code: '49001010001')

    get admin_rdap_privilege_grants_path

    assert_response :success
    assert_no_match '49001010001', response.body
  end

  # --- AC27: no missing translations on rendered pages -------------------------
  def test_rendered_pages_have_no_missing_translations
    [admin_rdap_privilege_grants_path,
     new_admin_rdap_privilege_grant_path,
     admin_rdap_privilege_grant_path(@grant),
     edit_admin_rdap_privilege_grant_path(@grant)].each do |path|
      get path
      assert_response :success
      assert_no_match(/translation missing/i, response.body, "missing translation on #{path}")
    end
  end

  private

  def valid_params
    {
      eeid_subject: 'EE39912310123',
      full_name: 'New Grantee',
      legal_basis_ref: 'MoU-2026-777',
      organization: 'police',
      category: 'police',
      valid_from: 1.day.ago,
      notes: 'lawful access',
    }
  end

  def non_admin_user
    AdminUser.create!(username: 'plain_admin',
                      email: 'plain@registry.test',
                      country_code: 'US',
                      password: 'testtest',
                      password_confirmation: 'testtest',
                      roles: ['user'])
  end
end
