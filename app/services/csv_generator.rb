class CsvGenerator
  def self.generate_csv(objects)
    class_name = objects.first.class
    return objects.to_csv unless custom_csv(class_name)

    CSV.generate do |csv|
      csv << class_name.csv_header
      objects.each { |object| csv << object.as_csv_row }
    end
  end

  private

  def self.custom_csv(class_name)
    [Version::DomainVersion, Version::ContactVersion, Domain].include?(class_name)
  end
end
