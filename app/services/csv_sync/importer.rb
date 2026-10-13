require 'csv'

class CsvSync::Importer
  Result = Struct.new(:created, :updated, :unchanged, :errors, :row_results, keyword_init: true) do
    def total
      created + updated + unchanged + errors
    end
  end

  def self.preview(model_class:, file:, fields: nil)
    new(model_class: model_class, file: file, fields: fields).preview
  end

  def self.apply(model_class:, file:, fields: nil)
    new(model_class: model_class, file: file, fields: fields).apply
  end

  def initialize(model_class:, file:, fields: nil)
    @model_class = model_class
    @file = file
    @fields = normalize_fields(fields)
  end

  def preview
    process_rows(persist: false)
  end

  def apply
    process_rows(persist: true)
  end

  private

  attr_reader :model_class, :file, :fields

  def process_rows(persist:)
    rows = parse_rows
    ensure_key_headers!(rows.headers)

    row_results = rows.map.with_index(2) do |row, line_number|
      process_row(row, line_number: line_number, persist: persist)
    rescue StandardError => e
      build_error_result(line_number: line_number, error: e.message)
    end

    summarize(row_results)
  end

  def process_row(row, line_number:, persist:)
    key_values = parse_key_values(row)
    record = find_record(key_values)
    attrs = parse_import_attrs(row)

    if record
      diff_attrs = changed_attrs(record, attrs)
      return build_row_result(line_number: line_number, action: :unchanged) if diff_attrs.empty?

      if persist
        apply_update!(record, diff_attrs)
      else
        record.assign_attributes(diff_attrs)
        raise ActiveRecord::RecordInvalid, record unless record.valid?
      end

      build_row_result(
        line_number: line_number,
        action: :updated,
        key_values: key_values,
        changes: diff_attrs.keys
      )
    else
      create_attrs = key_values.merge(attrs)

      if persist
        apply_create!(create_attrs)
      else
        preview_record = model_class.new(create_attrs)
        raise ActiveRecord::RecordInvalid, preview_record unless preview_record.valid?
      end

      build_row_result(line_number: line_number, action: :created, key_values: key_values)
    end
  rescue ActiveRecord::RecordInvalid => e
    build_error_result(
      line_number: line_number,
      key_values: key_values,
      error: e.record.errors.full_messages.to_sentence
    )
  rescue ArgumentError, TypeError => e
    build_error_result(line_number: line_number, key_values: key_values, error: e.message)
  end

  def parse_rows
    io = file.respond_to?(:tempfile) ? file.tempfile : file
    io.rewind if io.respond_to?(:rewind)
    content = io.read
    CSV.parse(content, headers: true, col_sep: detect_col_sep(content))
  end

  def detect_col_sep(content)
    first_line = content.to_s.each_line.first.to_s
    comma_count = first_line.count(',')
    semicolon_count = first_line.count(';')
    semicolon_count > comma_count ? ';' : ','
  end

  def parse_key_values(row)
    model_class.csv_sync_key_fields.each_with_object({}) do |field, acc|
      header = field.to_s
      raw_value = row[header]
      if raw_value.blank?
        raise ArgumentError, "Missing #{header} value"
      end

      acc[field] = model_class.csv_sync_import_value(field, raw_value)
    end
  end

  def parse_import_attrs(row)
    fields.each_with_object({}) do |field, acc|
      next if model_class.csv_sync_key_fields.include?(field)

      header = field.to_s
      next unless row.headers.include?(header)

      acc[field] = model_class.csv_sync_import_value(field, row[header])
    end
  end

  def ensure_key_headers!(headers)
    missing_headers = model_class.csv_sync_key_fields.map(&:to_s) - headers
    return if missing_headers.empty?

    raise ArgumentError, "Missing required CSV headers: #{missing_headers.join(', ')}"
  end

  def normalize_fields(fields)
    allowed_fields = model_class.csv_sync_fields
    selected_fields = Array(fields).map(&:to_sym).select { |field| allowed_fields.include?(field) }
    selected_fields = model_class.csv_sync_default_import_fields if selected_fields.empty?

    (model_class.csv_sync_key_fields + selected_fields).uniq
  end

  def find_record(key_values)
    scope = model_class.all

    key_values.each do |field, value|
      if value.is_a?(String)
        column_name = model_class.connection.quote_column_name(field)
        scope = scope.where("UPPER(#{column_name}) = ?", value.upcase)
      else
        scope = scope.where(field => value)
      end
    end

    scope.first
  end

  def changed_attrs(record, attrs)
    attrs.each_with_object({}) do |(field, value), changes|
      changes[field] = value if record.public_send(field) != value
    end
  end

  def apply_create!(attrs)
    if model_class.respond_to?(:csv_sync_create_record)
      model_class.csv_sync_create_record(attrs)
      return
    end

    if model_class.name == 'Registrar'
      create_registrar!(attrs)
      return
    end

    model_class.create!(attrs)
  end

  def apply_update!(record, attrs)
    if model_class.respond_to?(:csv_sync_update_record)
      model_class.csv_sync_update_record(record, attrs)
      return
    end

    record.update!(attrs)
  end

  def create_registrar!(attrs)
    registrar = model_class.new(attrs)
    registrar.reference_no ||= ::Billing::ReferenceNo.generate(owner: registrar.name)

    registrar.transaction do
      registrar.save!
      registrar.accounts.create!(account_type: Account::CASH, currency: 'EUR')
    end
  end

  def summarize(row_results)
    Result.new(
      created: row_results.count { |result| result[:action] == :created },
      updated: row_results.count { |result| result[:action] == :updated },
      unchanged: row_results.count { |result| result[:action] == :unchanged },
      errors: row_results.count { |result| result[:action] == :error },
      row_results: row_results
    )
  end

  def build_row_result(line_number:, action:, key_values: {}, changes: [])
    {
      line_number: line_number,
      action: action,
      key_values: key_values,
      changes: changes,
    }
  end

  def build_error_result(line_number:, key_values: {}, error:)
    build_row_result(
      line_number: line_number,
      action: :error,
      key_values: key_values,
      changes: []
    ).merge(error: error)
  end
end
