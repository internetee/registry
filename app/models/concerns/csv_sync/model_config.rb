module CsvSync::ModelConfig
  extend ActiveSupport::Concern

  BOOLEAN_TRUE_VALUES = %w[1 true t yes y on].freeze
  BOOLEAN_FALSE_VALUES = %w[0 false f no n off].freeze

  class_methods do
    def csv_sync_field_definitions
      const_get(:FIELD_DEFINITIONS)
    end

    def csv_sync_fields
      csv_sync_field_definitions.keys
    end

    def csv_sync_key_fields
      csv_sync_field_definitions.filter_map { |field, config| field if config[:key] }
    end

    def csv_sync_default_export_fields
      csv_sync_field_definitions.filter_map { |field, config| field if config[:default_export] }
    end

    def csv_sync_default_import_fields
      csv_sync_field_definitions.filter_map { |field, config| field if config[:default_import] }
    end

    def csv_sync_type_for(field)
      csv_sync_field_definitions.fetch(field.to_sym).fetch(:type)
    end

    def csv_sync_import_value(field, raw_value)
      csv_sync_deserialize(raw_value, type: csv_sync_type_for(field))
    end

    def csv_sync_export_value(field, value)
      csv_sync_serialize(value, type: csv_sync_type_for(field))
    end

    private

    def csv_sync_serialize(value, type:)
      return nil if value.nil?

      case type
      when :boolean
        value ? 'true' : 'false'
      when :decimal
        value.to_s
      when :datetime
        value.respond_to?(:iso8601) ? value.iso8601 : value.to_s
      when :json
        value.to_json
      else
        value.to_s
      end
    end

    def csv_sync_deserialize(raw_value, type:)
      value = raw_value.is_a?(String) ? raw_value.strip : raw_value
      return nil if value.blank?

      case type
      when :boolean
        parse_csv_sync_boolean(value)
      when :decimal
        BigDecimal(value.to_s)
      when :datetime
        Time.zone.parse(value.to_s)
      when :json
        parse_csv_sync_json(value)
      else
        value
      end
    end

    def parse_csv_sync_boolean(value)
      normalized = value.to_s.strip.downcase
      return true if BOOLEAN_TRUE_VALUES.include?(normalized)
      return false if BOOLEAN_FALSE_VALUES.include?(normalized)

      raise ArgumentError, "Invalid boolean value: #{value.inspect}"
    end

    def parse_csv_sync_json(value)
      case value
      when Hash
        value
      else
        JSON.parse(value.to_s)
      end
    rescue JSON::ParserError => e
      raise ArgumentError, "Invalid JSON value: #{e.message}"
    end
  end

  def csv_sync_export_value(field)
    self.class.csv_sync_export_value(field, public_send(field))
  end

  def csv_sync_import_value(field, raw_value)
    self.class.csv_sync_import_value(field, raw_value)
  end
end
