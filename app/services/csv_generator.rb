class CsvGenerator
  class << self
    def generate_csv(objects)
      @class_name = objects.first.class
      return default_generation(objects) unless custom_csv?

      CSV.generate do |csv|
        csv << @class_name.csv_header
        objects.each { |object| csv << object.as_csv_row }
      end
    end

    private

    def default_generation(objects)
      CSV.generate do |csv|
        csv << @class_name.column_names
        objects.each { |object| csv << object.attributes.values_at(*@class_name.column_names) }
      end
    end

    def custom_csv?
      [
        Version::DomainVersion,
        Version::ContactVersion,
        Domain,
        Contact,
        Invoice,
        Account,
        AccountActivity
      ].include?(@class_name)
    end
  end
end
