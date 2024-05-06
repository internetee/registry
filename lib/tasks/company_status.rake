require 'csv'
require 'open-uri'
require 'zip'
require 'net/http'
require 'uri'

# 16526891 - liquidated (L)
# 12489420 - registered (R)
# 11876557 - bankrupt (N)
#  K – deleted

namespace :company_status do
  desc 'Get Estonian companies status from Business Registry'

  DELETED_FROM_REGISTRY_STATUS = 'K'

  task :check_all => :environment do
    open_data_file_path = 'lib/tasks/data/ettevotja_rekvisiidid__lihtandmed.csv'
    output_file_path = 'lib/tasks/data/temp_missing_companies_output.csv'
    missing_companies_in_business_registry_path = 'lib/tasks/data/missing_companies_in_business_registry.csv'
    deleted_companies_from_business_registry_path = 'lib/tasks/data/delted_companies_from_business_registry.csv'

    puts "*** Run 1 step. Downloading fresh open data file. ***"

    # Download file
    url = 'https://avaandmed.ariregister.rik.ee/sites/default/files/avaandmed/ettevotja_rekvisiidid__lihtandmed.csv.zip'
    filename = 'ettevotja_rekvisiidid__lihtandmed.csv.zip'
    download_open_data_file(url, filename)

    # Unzip file
    destination = 'lib/tasks/data/'
    unzip_dile(filename, destination)

    # Remove old file
    remove_old_file(output_file_path)

    puts "*** Run 2 step. Collecting companies what are not in the open data file. ***"
    collect_companies_whats_not_in_open_data_file(open_data_file_path, output_file_path)

    puts "*** Run 3 step. Fetching detailed information from business registry. ***"
    sort_missing_companies_to_different_files(output_file_path, missing_companies_in_business_registry_path, deleted_companies_from_business_registry_path)
  end

  def remove_old_file(output_file_path)
    FileUtils.rm(output_file_path) if File.exist?(output_file_path)
  end


  def unzip_dile(filename, destination)
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
        unless codes_in_csv.include?(contact.ident)
          csv << [contact.id, contact.ident, contact.name]
        end
      end
    end
  end

  def sort_missing_companies_to_different_files(output_file_path, missing_companies_in_business_registry_path, deleted_companies_from_business_registry_path)
    collect_missing_companies_ids(output_file_path).each do |id|
      puts "Fetching data for ID: #{id}"
      
      contact = Contact.find(id.to_i)
      resp = contact.return_company_details
      contact_no_in_business_registry = []
      contact_which_were_deleted = []

      if resp.empty?
        contact_no_in_business_registry << [contact.id, contact.ident, contact.name]
      else
        status = resp.first.status.upcase
        contact_which_were_deleted << [contact.id, contact.ident, contact.name, status, resp.first.kandeliik] if status == DELETED_FROM_REGISTRY_STATUS
      end

      sleep 1
    end

    save_missing_companies(contact_no_in_business_registry)
    save_deleted_companies(contact_which_were_deleted)
  end

  def collect_missing_companies_ids(output_file_path)
    ids = []
    CSV.foreach(output_file_path, headers: true, quote_char: '"', liberal_parsing: true) do |row|
      ids << row['ID']
    end

    ids
  end

  def save_missing_companies(contact_no_in_business_registry)
    CSV.open(missing_companies_in_business_registry_path, 'wb', write_headers: true, headers: ["ID"]) do |csv|
      contact_no_in_business_registry.each do |id|
        csv << [id]
      end
    end
  end

  def save_deleted_companies(contact_which_were_deleted)
    CSV.open(deleted_companies_from_business_registry_path, 'wb', write_headers: true, headers: ["ID"]) do |csv|
      contact_which_were_deleted.each do |id|
        csv << [id]
      end
    end
  end
end
