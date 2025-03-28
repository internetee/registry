require 'test_helper'
require 'active_record_result_combiner'

class ActiveRecordResultCombinerTest < ActiveSupport::TestCase
  def setup
    setup_basic_results
    setup_different_data_types
    setup_null_values
    setup_different_column_counts
  end

  def setup_basic_results
    @result1 = ActiveRecord::Result.new(
      %w[column1 column2],
      [[1, 2], [3, 4]]
    )

    @result2 = ActiveRecord::Result.new(
      %w[column1 column2],
      [[5, 6], [7, 8]]
    )

    @result3 = ActiveRecord::Result.new(
      %w[column1 column2],
      [[9, 10], [11, 12]]
    )
  end

  def setup_different_data_types
    @mixed_result1 = ActiveRecord::Result.new(
      %w[string_col int_col float_col],
      [
        ['test', 1, 1.5],
        ['example', 2, 2.5]
      ]
    )

    @mixed_result2 = ActiveRecord::Result.new(
      %w[string_col int_col float_col],
      [
        ['test', 3, 3.5],
        ['example', 4, 4.5]
      ]
    )
  end

  def setup_null_values
    @null_result1 = ActiveRecord::Result.new(
      %w[column1 column2],
      [[1, nil], [nil, 4]]
    )

    @null_result2 = ActiveRecord::Result.new(
      %w[column1 column2],
      [[5, nil], [nil, 8]]
    )
  end

  def setup_different_column_counts
    @wide_result1 = ActiveRecord::Result.new(
      %w[col1 col2 col3 col4],
      [[1, 2, 3, 4], [5, 6, 7, 8]]
    )

    @wide_result2 = ActiveRecord::Result.new(
      %w[col1 col2 col3 col4],
      [[9, 10, 11, 12], [13, 14, 15, 16]]
    )
  end

  # Basic functionality tests
  def test_combine_results_with_differences
    combined_result = ActiveRecordResultCombiner.combine_results([@result1, @result2])

    expected_columns = [
      'column1 (1)', 'column2 (1)',
      'column1 (2)', 'column1 Diff (1->2)', 'column1 Diff %(1->2)',
      'column2 (2)', 'column2 Diff (1->2)', 'column2 Diff %(1->2)']
    expected_rows = [
      [1, 2, 5, 4.0, 400.0, 6, 4.0, 200.0], [3, 4, 7, 4.0, 133.33, 8, 4.0, 100.0]
    ]

    assert_equal expected_columns, combined_result.columns
    assert_equal expected_rows, combined_result.rows
  end

  def test_combine_three_results_with_differences
    combined_result = ActiveRecordResultCombiner.combine_results([@result1, @result2, @result3])

    expected_columns = [
      'column1 (1)', 'column2 (1)', 'column1 (2)', 'column1 Diff (1->2)', 'column1 Diff %(1->2)',
      'column2 (2)', 'column2 Diff (1->2)', 'column2 Diff %(1->2)',
      'column1 (3)', 'column1 Diff (2->3)', 'column1 Diff %(2->3)', 'column2 (3)',
      'column2 Diff (2->3)', 'column2 Diff %(2->3)'
    ]
    expected_rows = [
      [1, 2, 5, 4.0, 400.0, 6, 4.0, 200.0, 9, 4.0, 80.0, 10, 4.0, 66.67],
      [3, 4, 7, 4.0, 133.33, 8, 4.0, 100.0, 11, 4.0, 57.14, 12, 4.0, 50.0]
    ]

    assert_equal expected_columns, combined_result.columns
    assert_equal expected_rows, combined_result.rows
  end

  # Edge cases
  def test_combine_results_with_single_result
    combined_result = ActiveRecordResultCombiner.combine_results([@result1])

    expected_columns = %w[column1 column2]
    expected_rows = [[1, 2], [3, 4]]

    assert_equal expected_columns, combined_result.columns
    assert_equal expected_rows, combined_result.rows
  end

  def test_combine_results_with_no_results
    combined_result = ActiveRecordResultCombiner.combine_results([])

    assert_empty combined_result.columns
    assert_empty combined_result.rows
  end

  # Different data type tests
  def test_combine_results_with_different_data_types
    combined_result = ActiveRecordResultCombiner.combine_results([@mixed_result1, @mixed_result2])

    expected_columns = [
      'string_col', 'int_col (1)', 'float_col (1)',
      'int_col (2)', 'int_col Diff (1->2)', 'int_col Diff %(1->2)',
      'float_col (2)', 'float_col Diff (1->2)',
      'float_col Diff %(1->2)'
    ]
    expected_rows = [
      ['test', 1, 1.5, 3, 2.0, 200.0, 3.5, 2.0, 133.33],
      ['example', 2, 2.5, 4, 2.0, 100.0, 4.5, 2.0, 80.0]
    ]

    assert_equal expected_columns, combined_result.columns
    assert_equal expected_rows, combined_result.rows
  end

  # Null value handling tests
  def test_combine_results_with_null_values
    combined_result = ActiveRecordResultCombiner.combine_results([@null_result1, @null_result2])

    expected_columns = [
      'column1 (1)', 'column2 (1)',
      'column1 (2)', 'column1 Diff (1->2)', 'column1 Diff %(1->2)',
      'column2 (2)', 'column2 Diff (1->2)', 'column2 Diff %(1->2)'
    ]

    expected_rows = [
      [1, nil, 5, 4.0, 400.0, nil, nil, nil], [nil, 4, nil, nil, nil, 8, 4.0, 100.0]
    ]

    assert_equal expected_columns, combined_result.columns
    assert_equal expected_rows, combined_result.rows
  end

  # Wide result tests
  def test_combine_results_with_multiple_columns
    combined_result = ActiveRecordResultCombiner.combine_results([@wide_result1, @wide_result2])

    expected_column_count = 16 # 4 original + 4 second result + 8 differences
    assert_equal expected_column_count, combined_result.columns.length

    # Check differences for all numeric columns
    first_row_differences = combined_result.rows[0][-4..]
    assert_equal [266.67, 12, 8.0, 200.0], first_row_differences
  end
end
