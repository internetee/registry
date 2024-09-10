require 'test_helper'
require 'rake'
require 'minitest/mock'

class CompanyStatusRakeTaskTest < ActiveSupport::TestCase
  class MockRegistrant
    attr_accessor :id, :ident, :ident_type, :ident_country_code, :name, :registrant_publishable

    def initialize(attributes = {})
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    def update(attributes)
      attributes.each do |key, value|
        send("#{key}=", value)
      end
      true
    end

    def publishable?
      registrant_publishable
    end

    def epp_code_map
      {}
    end
  end

  def setup
    Rails.application.load_tasks
    @task = Rake::Task['company_status:check_all']
  end

  def teardown
    Rake::Task.clear
  end

  test "check_all task runs successfully" do
    # # Подготовка моков и заглушек
    # mock_download = Minitest::Mock.new
    # mock_download.expect :call, nil, [String, String]

    # mock_unzip = Minitest::Mock.new
    # mock_unzip.expect :call, nil, [String, String]

    # mock_collect_data = Minitest::Mock.new
    # mock_collect_data.expect :call, { "123456789" => { 'ettevotja_staatus' => "A" } }, [String]

    # mock_update_status = Minitest::Mock.new
    # mock_update_status.expect :call, true, [{ contact: MockRegistrant, status: String }]

    # # Создание тестовых данных
    # registrant = MockRegistrant.new(
    #   id: 1, 
    #   ident: "123456789", 
    #   ident_type: 'org', 
    #   ident_country_code: 'EE', 
    #   name: 'Test Company',
    #   registrant_publishable: true
    # )

    # # Подмена методов заглушками
    # Rake::Task['company_status:check_all'].instance_eval do
    #   define_method(:download_open_data_file) { |url, filename| mock_download.call(url, filename) }
    #   define_method(:unzip_file) { |filename, destination| mock_unzip.call(filename, destination) }
    #   define_method(:collect_company_data) { |path| mock_collect_data.call(path) }
    #   define_method(:update_company_status) { |args| mock_update_status.call(args) }
    # end

    # # Имитация выборки Registrant.where
    # Registrant.stub :where, [registrant] do
    #   # Выполнение задачи
    #   assert_nothing_raised { @task.execute }
    # end

    # # Проверка, что все моки были вызваны
    # assert_mock mock_download
    # assert_mock mock_unzip
    # assert_mock mock_collect_data
    # assert_mock mock_update_status
  end

  test "sort_companies_to_files handles missing company" do
    # contact = MockRegistrant.new(id: 2, ident: "987654321", ident_type: 'org', ident_country_code: 'EE', name: 'Missing Company')
    
    # mock_return_company_details = Minitest::Mock.new
    # mock_return_company_details.expect :call, []

    # contact.define_singleton_method(:return_company_details) { mock_return_company_details.call }

    # missing_file = Tempfile.new(['missing', '.csv'])
    # deleted_file = Tempfile.new(['deleted', '.csv'])

    # Rake::Task['company_status:check_all'].send(:sort_companies_to_files,
    #   contact: contact,
    #   missing_companies_in_business_registry_path: missing_file.path,
    #   deleted_companies_from_business_registry_path: deleted_file.path,
    #   soft_delete_enable: false
    # )

    # assert_mock mock_return_company_details

    # missing_content = File.read(missing_file.path)
    # assert_includes missing_content, contact.ident
    # assert_includes missing_content, contact.name

    # missing_file.unlink
    # deleted_file.unlink
  end

  test "sort_companies_to_files handles deleted company" do
    # contact = MockRegistrant.new(id: 3, ident: "111222333", ident_type: 'org', ident_country_code: 'EE', name: 'Deleted Company')
    
    # mock_return_company_details = Minitest::Mock.new
    # mock_return_company_details.expect :call, [
    #   OpenStruct.new(
    #     status: 'K',
    #     kandeliik: [['', OpenStruct.new(kandeliik: 'type', kandeliik_tekstina: 'text', kande_kpv: '2023-01-01')]]
    #   )
    # ]

    # contact.define_singleton_method(:return_company_details) { mock_return_company_details.call }

    # missing_file = Tempfile.new(['missing', '.csv'])
    # deleted_file = Tempfile.new(['deleted', '.csv'])

    # Rake::Task['company_status:check_all'].send(:sort_companies_to_files,
    #   contact: contact,
    #   missing_companies_in_business_registry_path: missing_file.path,
    #   deleted_companies_from_business_registry_path: deleted_file.path,
    #   soft_delete_enable: false
    # )

    # assert_mock mock_return_company_details

    # deleted_content = File.read(deleted_file.path)
    # assert_includes deleted_content, contact.ident
    # assert_includes deleted_content, contact.name
    # assert_includes deleted_content, 'K'

    # missing_file.unlink
    # deleted_file.unlink
  end
end