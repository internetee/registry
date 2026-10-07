require 'test_helper'
require 'csv'

class AdminAreaRegistrarsCsvSyncTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess

  setup do
    sign_in users(:admin)
    @bestnames = registrars(:bestnames)
    @goodnames = registrars(:goodnames)
  end

  def test_exports_filtered_registrars_as_csv
    get admin_registrars_path(format: :csv), params: { q: { name_cont: @bestnames.name } }

    assert_response :ok
    assert_equal 'text/csv', response.headers['Content-Type']
    assert_includes response.headers['Content-Disposition'], "registrars-#{Time.zone.today}.csv"

    csv = CSV.parse(response.body, headers: true)
    exported_codes = csv.map { |row| row['code'] }

    assert_includes csv.headers, 'code'
    assert_includes exported_codes, @bestnames.code
    refute_includes exported_codes, @goodnames.code
  end

  def test_exports_selected_registrars_as_csv
    get admin_registrars_path(format: :csv), params: {
      export_selected: '1',
      registrar_ids: [@goodnames.id],
      csv_fields: %w[name email]
    }

    assert_response :ok

    csv = CSV.parse(response.body, headers: true)
    assert_equal %w[code name email], csv.headers
    assert_equal 1, csv.length
    assert_equal @goodnames.code, csv[0]['code']
  end

  def test_exports_only_header_when_selected_export_has_no_ids
    get admin_registrars_path(format: :csv), params: { export_selected: '1', registrar_ids: [''] }

    assert_response :ok

    csv = CSV.parse(response.body, headers: true)
    assert_equal 0, csv.length
    assert_includes csv.headers, 'code'
  end

  def test_import_preview_renders_summary_for_valid_csv
    post import_preview_admin_registrars_path, params: {
      file: fixture_file_upload('files/registrars/import_update.csv', 'text/csv'),
      fields: %w[name email address_street address_city address_country_code language]
    }

    assert_response :success
    assert_includes response.body, I18n.t('admin.registrars.import_preview.header')
    assert_includes response.body, I18n.t('admin.csv_sync.preview_summary.panel_title')
    assert_match(/name="import_token"[^>]*value="[^"]+"/, response.body)
  end

  def test_import_preview_accepts_semicolon_delimited_csv
    semicolon_csv = <<~CSV
      code;name;email;address_street;address_city;address_country_code;language
      BESTNAMES;Best Names Updated Again;semicolon-best@example.test;Semicolon Street 10;NY;US;en
    CSV

    post import_preview_admin_registrars_path, params: {
      file: Rack::Test::UploadedFile.new(StringIO.new(semicolon_csv), 'text/csv', original_filename: 'registrars-semicolon.csv'),
      fields: %w[name email address_street address_city address_country_code language]
    }

    assert_response :success
    assert_includes response.body, I18n.t('admin.registrars.import_preview.header')
    assert_includes response.body, I18n.t('admin.csv_sync.preview_summary.panel_title')
    assert_no_match(/Failed to generate import preview/, response.body)
  end

  def test_import_preview_renders_import_page_when_file_is_missing
    post import_preview_admin_registrars_path, params: { fields: %w[name email] }

    assert_response :success
    assert_includes response.body, I18n.t('admin.registrars.import.header')
    assert_equal I18n.t('admin.registrars.import_preview.file_required'), flash[:alert]
  end

  def test_import_apply_updates_existing_registrar
    assert_not_equal 'updated-best@example.test', @bestnames.email

    post import_apply_admin_registrars_path, params: {
      file: fixture_file_upload('files/registrars/import_update.csv', 'text/csv'),
      fields: %w[name email address_street address_city address_country_code language]
    }

    assert_redirected_to admin_registrars_path
    assert_includes flash[:notice], '1 updated'

    @bestnames.reload
    assert_equal 'Best Names Updated', @bestnames.name
    assert_equal 'updated-best@example.test', @bestnames.email
  end

  def test_import_apply_creates_new_registrar_and_cash_account
    assert_nil Registrar.find_by(code: 'CSVNEW')

    Billing::ReferenceNo.stub(:generate, '998877665544332211') do
      post import_apply_admin_registrars_path, params: {
        file: fixture_file_upload('files/registrars/import_create.csv', 'text/csv'),
        fields: %w[name reg_no email address_street address_city address_country_code accounting_customer_code language]
      }
    end

    assert_redirected_to admin_registrars_path
    assert_includes flash[:notice], '1 created'

    created = Registrar.find_by(code: 'CSVNEW')
    assert_not_nil created
    assert_not_nil created.cash_account
  end

  def test_import_apply_redirects_when_file_missing
    post import_apply_admin_registrars_path, params: { fields: %w[name email] }

    assert_redirected_to import_admin_registrars_path
    assert_equal I18n.t('admin.registrars.import_apply.file_not_found'), flash[:alert]
  end
end
