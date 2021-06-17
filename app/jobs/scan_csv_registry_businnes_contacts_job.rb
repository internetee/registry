class ScanCsvRegistryBusinnesContactsJob < ApplicationJob
	FILE_NAME = './ettevotja_rekvisiidid_init.csv'.freeze
  def perform
		BusinessRegistryContact.delete_all

		return p 'File not exist!' unless File.exist?(FILE_NAME)

		CSV.foreach(FILE_NAME, headers: true, col_sep: ";") do |row|
			name = row[0]
			code = row[1]
			status = row[5]

			record = BusinessRegistryContact.create({
				name: name,
				registry_code: code,
				status: status
			})
			p "#{record} is successfully created - #{BusinessRegistryContact.count} count"
  	end
	end
end
