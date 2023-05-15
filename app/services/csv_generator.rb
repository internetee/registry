class CsvGenerator
  class << self
    def generate_csv(objects)
      class_name = objects.first.class
      return default_generation(objects) unless custom_csv?(class_name)

      CSV.generate do |csv|
        csv << class_name.csv_header
        objects.each { |object| csv << object.as_csv_row }
      end
    end

    private

    def default_generation(objects)
      CSV.generate do |csv|
        csv << objects.column_names
        objects.all.find_each { |object| csv << object.attributes.values_at(*objects.column_names) }
      end
    end

    def custom_csv?(class_name)
      [
        Version::DomainVersion, Version::ContactVersion, Domain,
        Contact, Invoice, Account, AccountActivity, ApiUser, WhiteIp
      ].include?(class_name)
    end
  end
end
