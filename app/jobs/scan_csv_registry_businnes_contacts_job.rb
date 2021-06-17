class ScanCsvRegistryBusinnesContactsJob < ApplicationJob
  def perform(filename)
    BusinessRegistryContact.delete_all

    return unless File.exist?(filename)

    enumurate_csv_file(filename)
  end

  private

  def enumurate_csv_file(filename)
    CSV.foreach(filename, headers: true, col_sep: ';') do |row|
      BusinessRegistryContact.create(
        name: row[0],
        registry_code: row[1],
        status: row[5]
      )
    end
  end
end
