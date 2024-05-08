require 'zip'

class CompanyRegisterStatusJob < ApplicationJob
  queue_as :default

  FILENAME = 'ettevotja_rekvisiidid__lihtandmed.csv.zip'
  UNZIP_FILENAME = 'ettevotja_rekvisiidid__lihtandmed.csv'
  DESTINATION = 'lib/tasks/data/'

  def perform(days_interval = 14, spam_time_delay = 0.2, batch_size = 100, download_open_data_file_url='https://avaandmed.ariregister.rik.ee/sites/default/files/avaandmed/ettevotja_rekvisiidid__lihtandmed.csv.zip')

    download_open_data_file(download_open_data_file_url, DESTINATION + FILENAME)
    unzip_file(FILENAME, DESTINATION)

    codes_in_csv = collect_company_codes(DESTINATION + UNZIP_FILENAME)

    sampling_registrant_contact(days_interval).find_in_batches(batch_size: batch_size) do |contacts|
      contacts.each do |contact|
        if codes_in_csv.include?(contact.ident)
          proceed_company_status(contact, spam_time_delay)
        else
          schedule_force_delete(contact)
        end
      end
    end

    remove_temp_file(DESTINATION + UNZIP_FILENAME)
  end

  private

  def proceed_company_status(contact, spam_time_delay)
    # avoid spamming company register
    sleep spam_time_delay

    company_status = contact.return_company_status
    contact.update!(company_register_status: company_status, checked_company_at: Time.zone.now)

    puts company_status
    case company_status
      when Contact::REGISTERED
        lift_force_delete(contact) if check_for_force_delete(contact)
      when Contact::LIQUIDATED
        ContactInformMailer.company_liquidation(contact: contact).deliver_now
      when Contact::BANKRUPT || Contact::DELETED
        schedule_force_delete(contact)
      end
  end

  def collect_company_codes(open_data_file_path)
    codes_in_csv = []
    CSV.foreach(open_data_file_path, headers: true, col_sep: ';', quote_char: '"', liberal_parsing: true) do |row|
      codes_in_csv << row['ariregistri_kood']
    end

    codes_in_csv
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

  def unzip_file(filename, destination)
    ::Zip::File.open(destination + filename) do |zip_file|
      zip_file.each do |entry|
        entry.extract(File.join(destination, entry.name)) { true } 
      end
    end

    puts "Archive invoke to #{destination}"
  end

  def sampling_registrant_contact(days_interval)
    Registrant.where(ident_type: 'org', ident_country_code: 'EE')
              .where('(company_register_status IS NULL) OR
                (company_register_status = ? AND (checked_company_at IS NULL OR checked_company_at <= ?)) OR
                (company_register_status = ? AND (checked_company_at IS NULL OR checked_company_at <= ?))',
              Contact::REGISTERED, days_interval.days.ago, Contact::LIQUIDATED, 1.day.ago)
  end
  
  def schedule_force_delete(contact)
    contact.domains.each do |domain|
      domain.schedule_force_delete(
        type: :fast_track,
        notify_by_email: true,
        reason: 'invalid_company',
        email: contact.email
      )
    end
  end

  def check_for_force_delete(contact)
    contact.domains.any? do |domain| 
      domain.schedule_force_delete? && domain.status_notes[DomainStatus::FORCE_DELETE].include?("Company no: #{contact.ident}")
    end
  end

  def lift_force_delete(contact)
    contact.domains.each do |domain|
      domain.lift_force_delete
    end
  end

  def remove_temp_file(distination)
    FileUtils.rm(distination) if File.exist?(distination)
  end
end
