class ScanCsvRegistryBusinnesContactsJob < ApplicationJob
  def perform(filename)
    BusinessRegistryContact.delete_all

    return p 'File not exist!' unless File.exist?(filename)

    enumurate_csv_file(filename)
  end

  private

  def enumurate_csv_file(filename)
    i = 0
    CSV.foreach(filename, headers: true, col_sep: ';') do |row|
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
