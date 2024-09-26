require 'csv'
require 'open-uri'
require 'zip'
require 'net/http'
require 'uri'
require 'optparse'
require 'rake_option_parser_boilerplate'

namespace :company_status do
  # bundle exec rake company_status:check_all -- --open_data_file_path=tmp/ettevotja_rekvisiidid__lihtandmed.csv --missing_companies_output_path=tmp/missing_companies_in_business_registry.csv --deleted_companies_output_path=tmp/deleted_companies_from_business_registry.csv --download_path=https://avaandmed.ariregister.rik.ee/sites/default/files/avaandmed/ettevotja_rekvisiidid__lihtandmed.csv.zip --soft_delete_enable=false --sleep_time=4 --registrants_only=true
  desc 'Get Estonian companies status from Business Registry.'

  DELETED_FROM_REGISTRY_STATUS = 'K'
  DESTINATION = Rails.root.join('tmp').to_s + '/'
  COMPANY_STATUS = 'ettevotja_staatus'
  BUSINESS_REGISTRY_CODE = 'ariregistri_kood'

  task :check_all => :environment do
    options = initialize_rake_task

    open_data_file_path = options[:open_data_file_path]
    missing_companies_in_business_registry_path = options[:missing_companies_output_path]
    deleted_companies_from_business_registry_path = options[:deleted_companies_output_path]
    download_path = options[:download_path]
    soft_delete_enable = options[:soft_delete_enable]
    downloaded_filename = File.basename(URI(download_path).path)
    are_registrants_only = options[:registrants_only]
    sleep_time = options[:sleep_time]

    puts "*** Run 1 step. Downloading fresh open data file. ***"
    remove_old_file(DESTINATION + downloaded_filename)
    download_open_data_file(download_path, downloaded_filename)
    unzip_file(downloaded_filename, DESTINATION)

    puts "*** Run 2 step. I am collecting data from open business registry sources. ***"
    company_data = collect_company_data(open_data_file_path)

    puts "*** Run 3 step. I process companies, update their information, and sort them into different files based on whether the companies are missing or removed from the business registry ***"

    whitelisted_companies = JSON.parse(ENV['whitelist_companies']) # ["12345678", "87654321"]    

    contacts_query = Contact.where(ident_type: 'org', ident_country_code: 'EE')

    if are_registrants_only
      contacts_query = contacts_query.joins(:registrant_domains).distinct
    end

    unique_contacts = contacts_query.to_a.uniq(&:ident)

    unique_contacts.each do |contact|
      next if whitelisted_companies.include?(contact.ident)

      if company_data.key?(contact.ident)
        update_company_status(contact: contact, status: company_data[contact.ident][COMPANY_STATUS])
        puts "Company: #{contact.name} with ident: #{contact.ident} and ID: #{contact.id} has status: #{company_data[contact.ident][COMPANY_STATUS]}"
      else
        update_company_status(contact: contact, status: 'K')
        sort_companies_to_files(
          contact: contact,
          missing_companies_in_business_registry_path: missing_companies_in_business_registry_path,
          deleted_companies_from_business_registry_path: deleted_companies_from_business_registry_path,
          soft_delete_enable: soft_delete_enable,
          sleep_time: sleep_time
        )
      end
    end

    puts '*** Done ***'
  end

  private

  def initialize_rake_task
    open_data_file_path = "#{DESTINATION}ettevotja_rekvisiidid__lihtandmed.csv"
    missing_companies_in_business_registry_path = "#{DESTINATION}missing_companies_in_business_registry.csv"
    deleted_companies_from_business_registry_path = "#{DESTINATION}deleted_companies_from_business_registry.csv"
    url = 'https://avaandmed.ariregister.rik.ee/sites/default/files/avaandmed/ettevotja_rekvisiidid__lihtandmed.csv.zip'

    options = {
      open_data_file_path: open_data_file_path,
      missing_companies_output_path: missing_companies_in_business_registry_path,
      deleted_companies_output_path: deleted_companies_from_business_registry_path,
      download_path: url,
      soft_delete_enable: false,
      registrants_only: false,
      sleep_time: 2,
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
      soft_delete_enable: ['-e [SOFT_DELETE_ENABLE]', '--soft_delete_enable [SOFT_DELETE_ENABLE]', FalseClass],
      registrants_only: ['-r', '--registrants_only [REGISTRANTS_ONLY]', FalseClass],
      sleep_time: ['-s', '--sleep_time [SLEEP_TIME]', Integer],
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

  def collect_company_data(open_data_file_path)
    company_data = {}

    CSV.foreach(open_data_file_path, headers: true, col_sep: ';', quote_char: '"', liberal_parsing: true) do |row|
      company_data[row[BUSINESS_REGISTRY_CODE]] = row
    end

    company_data
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

  def update_company_status(contact:, status:)
    contact.update(company_register_status: status, checked_company_at: Time.zone.now)
  end

  def put_company_to_missing_file(contact:, path:)
    write_to_csv_file(csv_file_path: path, headers: ["ID", "Ident", "Name", "Contact Type"], attrs: [contact.id, contact.ident, contact.name, determine_contact_type(contact)])
  end

  def sort_companies_to_files(contact:, missing_companies_in_business_registry_path:, deleted_companies_from_business_registry_path:, soft_delete_enable:, sleep_time:)
    sleep sleep_time
    puts "Sleeping for #{sleep_time} seconds"


    resp = contact.return_company_details

    if resp.empty?
      put_company_to_missing_file(contact: contact, path: missing_companies_in_business_registry_path)
      puts "Company: #{contact.name} with ident: #{contact.ident} and ID: #{contact.id} is missing in registry, company id: #{contact.id}"
      soft_delete_company(contact) if soft_delete_enable
    else
      status = resp.first.status.upcase
      kandeliik_type = resp.first.kandeliik.last.last.kandeliik
      kandeliik_tekstina = resp.first.kandeliik.last.last.kandeliik_tekstina
      kande_kpv = resp.first.kandeliik.last.last.kande_kpv

      if status == DELETED_FROM_REGISTRY_STATUS
        csv_file_path = deleted_companies_from_business_registry_path
        headers = ["ID", "Ident", "Name", "Status", "Kandeliik Type", "Kandeliik Tekstina", "kande_kpv", "Contact Type"]
        attrs = [contact.id, contact.ident, contact.name, status, kandeliik_type, kandeliik_tekstina, kande_kpv, determine_contact_type(contact)]
        write_to_csv_file(csv_file_path: csv_file_path, headers: headers, attrs: attrs)

        puts "Company: #{contact.name} with ident: #{contact.ident} and ID: #{contact.id} has status #{status}, company id: #{contact.id}"
        soft_delete_company(contact) if soft_delete_enable
      end
    end
  end

  def determine_contact_type(contact)
    roles = []
    roles << 'Registrant' if contact.registrant_domains.any?
    roles += contact.domain_contacts.pluck(:type).uniq if contact.domain_contacts.any?
    roles << 'Unknown' if roles.empty?
    roles.join(', ')
  end

  def soft_delete_company(contact)
    # contact.domains.reject { |domain| domain.force_delete_scheduled? }.each do |domain|
    #   domain.schedule_force_delete(type: :soft)
    # end
    # 
    
    contact.domains.each do |domain|
      next if domain.force_delete_scheduled?

      domain.schedule_force_delete(type: :soft)
      puts "Soft delete process initiated for company: #{contact.name} with ID: #{contact.id} domain: #{domain.name}"
    end

  end

  def write_to_csv_file(csv_file_path:, headers:, attrs:)
    write_headers = !File.exist?(csv_file_path)

    begin
      CSV.open(csv_file_path, "ab", write_headers: write_headers, headers: headers) do |csv|
        csv <<  attrs
      end
      puts "Successfully wrote to CSV: #{csv_file_path}"
    rescue => e
      puts "Error writing to CSV: #{e.message}"
    end
  end
end
