namespace :collect_csv_data do
  desc 'Import from csv registry business contact into BusinessRegistryContact model'

	FILE_NAME = './ettevotja_rekvisiidid_init.csv'.freeze

  task business_contacts: :environment do
    ScanCsvRegistryBusinnesContactsJob.perform_later(FILE_NAME)
  end
end
