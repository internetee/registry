require 'csv'

class CsvSync::Exporter
  def self.call(model_class:, records:, fields: nil)
    new(model_class: model_class, records: records, fields: fields).to_csv
  end

  def initialize(model_class:, records:, fields: nil)
    @model_class = model_class
    @records = records
    @fields = normalize_fields(fields)
  end

  def to_csv
    CSV.generate do |csv|
      csv << headers
      records.find_each do |record|
        csv << fields.map { |field| model_class.csv_sync_export_value(field, record.public_send(field)) }
      end
    end
  end

  private

  attr_reader :model_class, :records, :fields

  def normalize_fields(fields)
    allowed_fields = model_class.csv_sync_fields
    selected_fields = Array(fields).map(&:to_sym).select { |field| allowed_fields.include?(field) }
    selected_fields = model_class.csv_sync_default_export_fields if selected_fields.empty?

    (model_class.csv_sync_key_fields + selected_fields).uniq
  end

  def headers
    fields.map(&:to_s)
  end
end
