# Combines multiple ActiveRecord::Result objects, preserving data types and calculating differences for numeric columns
module ActiveRecordResultCombiner
  module_function

  def combine_results(results)
    return ActiveRecord::Result.new([], []) if results.empty?
    return results.first if results.size == 1

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

        # Add difference columns after each result except the first
        if results.size > 1 && index > 0 && numeric_columns.include?(col)
          prev_index = index
          curr_index = index + 1
          all_columns << "Diff (#{prev_index}->#{curr_index})"
          all_columns << "Diff %(#{prev_index}->#{curr_index})"
        end
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

    # Add data from all results and calculate differences
    results.each_with_index do |result, result_index|
      result.columns.each_with_index do |col, col_index|
        next if group_columns.include?(col)

        current_value = result.rows[index][col_index]
        row << current_value

        # Calculate differences with previous result
        if result_index > 0 && numeric_columns.include?(col)
          prev_value = results[result_index - 1].rows[index][col_index]
          differences = calculate_single_difference(prev_value, current_value)
          row.concat(differences)
        end
      end
    end

    row
  end

  def calculate_single_difference(prev_value, current_value)
    if prev_value.nil? || current_value.nil?
      [nil, nil]
    else
      difference = (prev_value.to_f - current_value.to_f).round(2)
      percentage = prev_value.to_f != 0 ? ((difference / prev_value.to_f) * 100).round(2) : nil
      [difference, percentage]
    end
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

  private_class_method :build_columns, :build_rows, :build_row, :calculate_single_difference, :identify_numeric_columns
end
