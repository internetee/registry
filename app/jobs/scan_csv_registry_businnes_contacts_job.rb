class ScanCsvRegistryBusinnesContactsJob < ApplicationJob
  FILE_NAME = './ettevotja_rekvisiidid_init.csv'.freeze

  def perform
    BusinessRegistryContact.delete_all

    return p 'File not exist!' unless File.exist?(FILE_NAME)

    enumurate_csv_file
  end

  private

  def enumurate_csv_file
    i = 0
    CSV.foreach(FILE_NAME, headers: true, col_sep: ';') do |row|
      record = BusinessRegistryContact.create(
        name: row[0],
        registry_code: row[1],
        status: row[5]
      )

      i += 1

      p "#{record} is successfully created - #{i} count"
    end
  end
end
