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

    expected_columns = ['column1 (1)', 'column2 (1)', 'column1 (2)', 'column2 (2)', 'column1 Difference', 'column2 Difference']
    expected_rows = [
      [1, 2, 5, 6, 4, 4],
      [3, 4, 7, 8, 4, 4]
    ]

    assert_equal expected_columns, combined_result.columns
    assert_equal expected_rows, combined_result.rows
  end

  def test_combine_three_results_with_differences
    combined_result = ActiveRecordResultCombiner.combine_results([@result1, @result2, @result3])

    expected_columns = [
      'column1 (1)', 'column2 (1)',      # First result columns
      'column1 (2)', 'column2 (2)',      # Second result columns
      'column1 (3)', 'column2 (3)',      # Third result columns
      'column1 Difference', 'column2 Difference'  # Differences between first and last
    ]
    expected_rows = [
      [1, 2, 5, 6, 9, 10, 8, 8],    # First row with differences (9-1=8, 10-2=8)
      [3, 4, 7, 8, 11, 12, 8, 8]    # Second row with differences (11-3=8, 12-4=8)
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
      'string_col',
      'int_col (1)', 'float_col (1)',    # First result numeric columns
      'int_col (2)', 'float_col (2)',    # Second result numeric columns
      'int_col Difference', 'float_col Difference' # Only numeric differences
    ]

    assert_equal expected_columns, combined_result.columns
    assert_equal 2, combined_result.rows.length

    first_row = combined_result.rows[0]
    # Check the structure of the first row
    assert_equal 'test', first_row[0]                    # string_col remains unchanged
    assert_equal 1, first_row[1]                         # int_col (1)
    assert_equal 1.5, first_row[2]                       # float_col (1)
    assert_equal 3, first_row[3]                         # int_col (2)
    assert_equal 3.5, first_row[4]                       # float_col (2)
    assert_equal 2, first_row[5]                         # int_col difference (3 - 1)
    assert_in_delta 2.0, first_row[6], 0.001            # float_col difference (3.5 - 1.5)

    # Verify second row follows the same pattern
    second_row = combined_result.rows[1]
    assert_equal 'example', second_row[0]                # string_col remains unchanged
    assert_equal 2, second_row[1]                        # int_col (1)
    assert_equal 2.5, second_row[2]                      # float_col (1)
    assert_equal 4, second_row[3]                        # int_col (2)
    assert_equal 4.5, second_row[4]                      # float_col (2)
    assert_equal 2, second_row[5]                        # int_col difference (4 - 2)
    assert_in_delta 2.0, second_row[6], 0.001           # float_col difference (4.5 - 2.5)
  end

  # Null value handling tests
  def test_combine_results_with_null_values
    combined_result = ActiveRecordResultCombiner.combine_results([@null_result1, @null_result2])

    expected_columns = ['column1 (1)', 'column2 (1)', 'column1 (2)', 'column2 (2)', 'column1 Difference', 'column2 Difference']

    assert_equal expected_columns, combined_result.columns
    assert_equal 2, combined_result.rows.length

    # Check that differences with nulls are handled gracefully
    assert_nil combined_result.rows[1][-2]  # Difference when both values are null
  end

  # Wide result tests
  def test_combine_results_with_multiple_columns
    combined_result = ActiveRecordResultCombiner.combine_results([@wide_result1, @wide_result2])

    expected_column_count = 12 # 4 original + 4 second result + 4 differences
    assert_equal expected_column_count, combined_result.columns.length

    # Check differences for all numeric columns
    first_row_differences = combined_result.rows[0][-4..]
    assert_equal [8, 8, 8, 8], first_row_differences
  end
end
