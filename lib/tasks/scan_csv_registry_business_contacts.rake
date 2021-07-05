namespace :collect_csv_data do
  desc 'Import from csv registry business contact into BusinessRegistryContact model'

  task business_contacts: :environment do
    ScanCsvRegistryBusinnesContactsJob.perform_later(filename)
  end

  private

  def filename
    './ettevotja_rekvisiidid_init.csv'
  end
end
