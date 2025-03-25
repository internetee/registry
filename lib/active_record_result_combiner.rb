module ActiveRecordResultCombiner
  module_function

  def combine_results(results)
    return ActiveRecord::Result.new([], []) if results.empty?

    columns = build_columns(results)
    rows = build_rows(results)

    ActiveRecord::Result.new(columns, rows)
  end

  def build_columns(results)
    return [] if results.empty?

    base_columns = results.first.columns
    all_columns = []

    # First, identify numeric columns from the first result
    numeric_columns = identify_numeric_columns(results.first)
    group_columns = base_columns - numeric_columns

    # Add group columns (without index)
    all_columns.concat(group_columns)

    # Add indexed columns for each result
    results.each_with_index do |result, index|
      result.columns.each do |col|
        next if group_columns.include?(col)

        col_name = col
        col_name += " (#{index + 1})" if results.size > 1
        all_columns << col_name
      end
    end

    # Add difference columns only for numeric columns
    if results.size > 1
      numeric_columns.each do |col|
        all_columns << "#{col} Difference"
      end
    end

    all_columns
  end

  def build_rows(results)
    return [] if results.empty?

    results.first.rows.each_index.map do |i|
      build_row(results, i)
    end
  end

  def build_row(results, index)
    first_row = results.first.rows[index]
    return first_row if results.size <= 1

    numeric_columns = identify_numeric_columns(results.first)
    group_columns = results.first.columns - numeric_columns

    row = []

    # Add group columns first
    group_columns.each_with_index do |col, col_index|
      row << first_row[col_index]
    end

    # Add data from all results (except group columns)
    results.each do |result|
      result.columns.each_with_index do |col, col_index|
        next if group_columns.include?(col)

        row << result.rows[index][col_index]
      end
    end

    # Add differences for numeric columns
    if results.size > 1
      differences = calculate_differences(results.first, results.last, index, numeric_columns)
      row.concat(differences)
    end

    row
  end

  def calculate_differences(first_result, last_result, row_index, numeric_columns)
    differences = []
    numeric_columns.each_with_index do |col, col_index|
      col_index_in_result = first_result.columns.index(col)
      first_value = first_result.rows[row_index][col_index_in_result]
      last_value = last_result.rows[row_index][col_index_in_result]

      if first_value.nil? || last_value.nil?
        differences << nil
      else
        differences << (last_value.to_f - first_value.to_f)
      end
    end
    differences
  end

  def identify_numeric_columns(result)
    return [] if result.rows.empty?

    result.columns.select.with_index do |col, index|
      # Check the first non-nil value in this column
      value = result.rows.find { |row| !row[index].nil? }&.at(index)
      next false if value.nil?

      # Consider it numeric if it can be converted to float without error
      begin
        Float(value.to_s)
        true
      rescue ArgumentError, TypeError
        false
      end
    end
  end

  private_class_method :build_columns, :build_rows, :build_row, :calculate_differences, :identify_numeric_columns
end
