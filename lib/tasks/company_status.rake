require 'csv'
require 'open-uri'
require 'zip'
require 'net/http'
require 'uri'
require 'optparse'
require 'rake_option_parser_boilerplate'


namespace :company_status do
  # bundle exec rake company_status:check_for_exists -- --open_data_file_path=lib/tasks/data/ettevotja_rekvisiidid__lihtandmed.csv --missing_companies_output_path=lib/tasks/data/missing_companies_in_business_registry.csv --deleted_companies_output_path=lib/tasks/data/deleted_companies_from_business_registry.csv --download_path=https://avaandmed.ariregister.rik.ee/sites/default/files/avaandmed/ettevotja_rekvisiidid__lihtandmed.csv.zip
  desc 'Get Estonian companies status from Business Registry.'

  DELETED_FROM_REGISTRY_STATUS = 'K'
  FILENAME = 'opendata_business_registry.csv.zip'
  DESTINATION = 'lib/tasks/data/'

  task :check_for_exists => :environment do
    options = initialize_rake_task

    open_data_file_path = options[:open_data_file_path]
    missing_companies_in_business_registry_path = options[:missing_companies_output_path]
    deleted_companies_from_business_registry_path = options[:deleted_companies_output_path]
    download_path = options[:download_path]
    output_file_path = 'lib/tasks/data/temp_missing_companies_output.csv'

    puts "*** Run 1 step. Downloading fresh open data file. ***"

    download_open_data_file(download_path, FILENAME)
    unzip_file(FILENAME, DESTINATION)

    # Remove old file
    remove_old_file(output_file_path)

    puts "*** Run 2 step. Collecting companies what are not in the open data file. ***"
    collect_companies_whats_not_in_open_data_file(open_data_file_path, output_file_path)

    puts "*** Run 3 step. Fetching detailed information from business registry. ***"
    sort_missing_companies_to_different_files(output_file_path, missing_companies_in_business_registry_path, deleted_companies_from_business_registry_path)

    puts '*** Run 4 step. Remove temporary files. ***'
    remove_old_file(output_file_path)
    FileUtils.rm(FILENAME) if File.exist?(FILENAME)

    puts '*** Done ***'
  end

  private

  def initialize_rake_task
    open_data_file_path = 'lib/tasks/data/ettevotja_rekvisiidid__lihtandmed.csv'
    missing_companies_in_business_registry_path = 'lib/tasks/data/missing_companies_in_business_registry.csv'
    deleted_companies_from_business_registry_path = 'lib/tasks/data/deleted_companies_from_business_registry.csv'
    url = 'https://avaandmed.ariregister.rik.ee/sites/default/files/avaandmed/ettevotja_rekvisiidid__lihtandmed.csv.zip'

    options = {
      open_data_file_path: open_data_file_path,
      missing_companies_output_path: missing_companies_in_business_registry_path,
      deleted_companies_output_path: deleted_companies_from_business_registry_path,
      download_path: url,
    }

    banner = 'Usage: rake companies:check_all -- [options]'
    RakeOptionParserBoilerplate.process_args(options: options,
                                                banner: banner,
                                                hash: companies_opts_hash)
  end

  def companies_opts_hash
    {
      open_data_file_path: ['-o [OPEN_DATA_FILE_PATH]', '--open_data_file_path [DOMAIN_NAME]', String],
      missing_companies_output_path: ['-m [MISSING_COMPANIES_OUTPUT_PATH]', '--missing_companies_output_path [MISSING_COMPANIES_OUTPUT_PATH]', String],
      deleted_companies_output_path: ['-s [DELETED_COMPANIES_OUTPUT_PATH]', '--deleted_companies_output_path [DELETED_COMPANIES_OUTPUT_PATH]', String],
      download_path: ['-d [DOWNLOAD_PATH]', '--download_path [DOWNLOAD_PATH]', String],
    }
  end

  def remove_old_file(output_file_path)
    FileUtils.rm(output_file_path) if File.exist?(output_file_path)
  end


  def unzip_file(filename, destination)
    Zip::File.open(filename) do |zip_file|
      zip_file.each do |entry|
        entry.extract(File.join(destination, entry.name)) { true } 
      end
    end

    puts "Archive invoke to #{destination}"
  end


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

  def collect_companies_whats_not_in_open_data_file(open_data_file_path, output_file_path)
    codes_in_csv = collect_company_codes(open_data_file_path)
    put_missing_companies_to_file(output_file_path, codes_in_csv)
  end

  def collect_company_codes(open_data_file_path)
    codes_in_csv = []
    CSV.foreach(open_data_file_path, headers: true, col_sep: ';', quote_char: '"', liberal_parsing: true) do |row|
      codes_in_csv << row['ariregistri_kood']
    end

    codes_in_csv
  end

  def put_missing_companies_to_file(output_file_path, codes_in_csv)
    CSV.open(output_file_path, 'wb', write_headers: true, headers: ["ID", "Code", "Name"]) do |csv|
      Contact.where(ident_type: 'org', ident_country_code: 'EE').find_each do |contact|
      # [16526891, 14836742, 12489420, 12226399, 12475122].each do |test_ident|
        # Contact.where(ident: test_ident).limit(100).each do |contact|
          unless codes_in_csv.include?(contact.ident)
            csv << [contact.id, contact.ident, contact.name]
          end
        # end
      end
    end
  end

  def sort_missing_companies_to_different_files(output_file_path, missing_companies_in_business_registry_path, deleted_companies_from_business_registry_path)
    contact_no_in_business_registry = []
    contact_which_were_deleted = []

    collect_missing_companies_ids(output_file_path).each do |id|
      puts "Fetching data for ID: #{id}"
      
      contact = Contact.find(id.to_i)

      resp = contact.return_company_details

      if resp.empty?
        contact_no_in_business_registry << [contact.id, contact.ident, contact.name]
      else
        status = resp.first.status.upcase
        kandeliik_type = resp.first.kandeliik.last.last.kandeliik
        kandeliik_tekstina = resp.first.kandeliik.last.last.kandeliik_tekstina
        kande_kpv = resp.first.kandeliik.last.last.kande_kpv

        if status == DELETED_FROM_REGISTRY_STATUS
          contact_which_were_deleted << [contact.id, contact.ident, contact.name, status, kandeliik_type, kandeliik_tekstina, kande_kpv]
        end
      end

      sleep 1
    end

    save_missing_companies(contact_no_in_business_registry, missing_companies_in_business_registry_path)
    save_deleted_companies(contact_which_were_deleted, deleted_companies_from_business_registry_path)
  end

  def collect_missing_companies_ids(output_file_path)
    ids = []
    CSV.foreach(output_file_path, headers: true, quote_char: '"', liberal_parsing: true) do |row|
      ids << row['ID']
    end

    ids
  end

  def save_missing_companies(contact_no_in_business_registry, missing_companies_in_business_registry_path)
    CSV.open(missing_companies_in_business_registry_path, 'wb', write_headers: true, headers: ["ID",  "Code", "Name"]) do |csv|
      contact_no_in_business_registry.each do |entry|
        csv << entry
      end
    end
  end

  def save_deleted_companies(contact_which_were_deleted, deleted_companies_from_business_registry_path)
    CSV.open(deleted_companies_from_business_registry_path, 'wb', write_headers: true, headers: ["ID", "Ident", "Name", "Status", "Kandeliik Type", "Kandeliik Tekstina", "kande_kpv"]) do |csv|
      contact_which_were_deleted.each do |entry|
        csv << entry
      end
    end
  end
end
