require 'test_helper'
require 'webmock/minitest'
require 'tempfile'
require 'csv'
require 'zip'

module CompanyStatusTaskTestOverrides
  def download_open_data_file(url, filename)
    uri = URI(url)
  
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
  
      if response.code == '200'
        File.open(filename, 'wb') do |file|
          file.write(response.body)
        end
      else
        puts "Failed to download file: #{response.code} #{response.message}"
      end
    end
  
    puts "File saved as #{filename}"
  end

  def unzip_file(filename, destination)
    Zip::File.open(filename) do |zip_file|
      zip_file.each do |entry|
        entry_path = File.join(destination, entry.name)
        entry.extract(entry_path) { true }  # Overwrite existing files
      end
    end
    true
  end

  def collect_company_data(open_data_file_path)
    $test_options = open_data_file_path
    # Return test data
    { '12345678' => { 'ettevotja_staatus' => 'active' } }
  end

  def update_company_status(contact:, status:)
    # Do nothing
  end

  def sort_companies_to_files(contact:, missing_companies_in_business_registry_path:, deleted_companies_from_business_registry_path:, soft_delete_enable:)
    # Do nothing
  end

  def initialize_rake_task
    options = {
      open_data_file_path: "#{DESTINATION}ettevotja_rekvisiidid__lihtandmed.csv",
      missing_companies_output_path: "#{DESTINATION}missing_companies_in_business_registry.csv",
      deleted_companies_output_path: "#{DESTINATION}deleted_companies_from_business_registry.csv",
      download_path: 'https://avaandmed.ariregister.rik.ee/sites/default/files/avaandmed/ettevotja_rekvisiidid__lihtandmed.csv.zip',
      soft_delete_enable: false,
      registrants_only: false,
    }

    # Process command line arguments
    RakeOptionParserBoilerplate.process_args(
      options: options,
      banner: 'Usage: rake company_status:check_all [options]',
      hash: {
        open_data_file_path: ['-o', '--open_data_file_path PATH', String],
        missing_companies_output_path: ['-m', '--missing_companies_output_path PATH', String],
        deleted_companies_output_path: ['-d', '--deleted_companies_output_path PATH', String],
        download_path: ['-u', '--download_path URL', String],
        soft_delete_enable: ['-s', '--soft_delete_enable', :NONE],
        registrants_only: ['-r', '--registrants_only', :NONE]
      }
    )

    options
  end
end

class CompanyStatusTaskTest < ActiveSupport::TestCase
  include CompanyStatusTaskTestOverrides

  def setup
    super  # Always call super when overriding setup

    # Create temporary CSV file with test data
    @temp_csv = Tempfile.new(['test_data', '.csv'])
    CSV.open(@temp_csv.path, 'wb') do |csv|
      csv << ['ariregistri_kood', 'ettevotja_staatus']
      csv << ['12345678', 'active']
    end

    @temp_csv_path = @temp_csv.path
    $temp_csv_path = @temp_csv.path  # Set the global variable

    # Create temporary zip file containing our CSV
    @temp_zip = Tempfile.new(['test_data', '.zip'])
    Zip::File.open(@temp_zip.path, Zip::File::CREATE) do |zipfile|
      zipfile.add('ettevotja_rekvisiidid__lihtandmed.csv', @temp_csv_path)
    end

    # Stub HTTP request
    stub_request(:get, 'https://avaandmed.ariregister.rik.ee/sites/default/files/avaandmed/ettevotja_rekvisiidid__lihtandmed.csv.zip')
      .to_return(status: 200, body: File.read(@temp_zip.path), headers: {})

    # Prepend the module to the main object to override methods
    main = TOPLEVEL_BINDING.eval('self')
    main.singleton_class.prepend(CompanyStatusTaskTestOverrides)
  end

  def teardown
    super  # Always call super when overriding teardown

    @temp_csv.close if @temp_csv
    @temp_csv.unlink if @temp_csv
    @temp_zip.close if @temp_zip
    @temp_zip.unlink if @temp_zip
    WebMock.reset!
  end

  test "initialize_rake_task sets default options correctly and handles file processing" do
    stub_request(:get, 'https://avaandmed.ariregister.rik.ee/sites/default/files/avaandmed/ettevotja_rekvisiidid__lihtandmed.csv.zip')
      .to_return(status: 200, body: File.read(@temp_zip.path), headers: {})

    ENV['whitelist_companies'] = '["12345678", "87654321"]'
    $test_options = nil

    # No need to prepend again; it's already done in setup

    # Stub external dependencies
    RakeOptionParserBoilerplate.stub :process_args, ->(options:, banner:, hash:) { options } do
      run_task

      # Assertions
      assert_not_nil $test_options, "Options should not be nil"

      expected_path = Rails.root.join('tmp', 'ettevotja_rekvisiidid__lihtandmed.csv').to_s
      assert_equal expected_path, $test_options

      # Add more assertions as needed
    end

    assert_requested :get, 'https://avaandmed.ariregister.rik.ee/sites/default/files/avaandmed/ettevotja_rekvisiidid__lihtandmed.csv.zip'
  end

  test "initialize_rake_task processes command line arguments" do
    simulated_args = [
      '--open_data_file_path=/custom/path.csv',
      '--missing_companies_output_path=/custom/missing.csv',
      '--deleted_companies_output_path=/custom/deleted.csv',
      '--download_path=https://example.com/custom.zip',
      '--soft_delete_enable',
      '--registrants_only'
    ]

    # Replace ARGV with simulated arguments
    original_argv = ARGV.dup
    ARGV.replace(simulated_args)

    # Stub RakeOptionParserBoilerplate to process ARGV
    RakeOptionParserBoilerplate.stub :process_args, ->(options:, banner:, hash:) {
      OptionParser.new do |opts|
        hash.each do |key, (short, long, type)|
          opts.on(*[short, long, type].compact) do |value|
            # Convert string 'true'/'false' to boolean if needed
            if [TrueClass, FalseClass].include?(type)
              value = true
            end
            options[key] = value
          end
        end
      end.parse!(ARGV)
      options
    } do
      options = initialize_rake_task

      # Assertions
      assert_equal '/custom/path.csv', options[:open_data_file_path]
      assert_equal '/custom/missing.csv', options[:missing_companies_output_path]
      assert_equal '/custom/deleted.csv', options[:deleted_companies_output_path]
      assert_equal 'https://example.com/custom.zip', options[:download_path]
      assert_equal true, options[:soft_delete_enable]
      assert_equal true, options[:registrants_only]
    end

    # Restore ARGV
    ARGV.replace(original_argv)
  end

  test "download_open_data_file downloads file successfully" do
    # Setup a temporary filename
    temp_filename = 'test_download.zip'

    # Stub the HTTP request
    stub_request(:get, 'https://example.com/test.zip')
      .to_return(status: 200, body: 'Test content', headers: {})

    # Call the actual method
    download_open_data_file('https://example.com/test.zip', temp_filename)

    # Assertions
    assert File.exist?(temp_filename), "File should exist after download"
    assert_equal 'Test content', File.read(temp_filename)

    assert_requested :get, 'https://example.com/test.zip'

    # Cleanup
    File.delete(temp_filename) if File.exist?(temp_filename)
  end

  test "unzip_file extracts contents correctly" do
    # Create a temporary zip file with known content
    temp_zip = Tempfile.new(['test', '.zip'])
    temp_dir = Dir.mktmpdir

    Zip::File.open(temp_zip.path, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream('test.txt') { |f| f.write 'Hello, world!' }
    end

    # Call the method
    unzip_file(temp_zip.path, temp_dir)

    # Assertions
    extracted_file = File.join(temp_dir, 'test.txt')
    puts "Extracted file path: #{extracted_file}"  # Add debug information
    puts "Directory contents: #{Dir.entries(temp_dir)}"  # Add debug information

    assert File.exist?(extracted_file), "File should be extracted"
    assert_equal 'Hello, world!', File.read(extracted_file)

    # Cleanup
    temp_zip.close
    temp_zip.unlink
    FileUtils.remove_entry(temp_dir)
  end

  def run_task
    Rake::Task['company_status:check_all'].execute
  end
end
