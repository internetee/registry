# require 'test_helper'
# require 'active_record_result_combiner'

# class ReportRunnerTest < ActiveSupport::TestCase
#   setup do
#     @report = reports(:one)
#     @params = ActionController::Parameters.new({ '0' => { 'start_date' => '2025-01-01' } })

#     # Save the original connection configuration
#     @original_db_config = ActiveRecord::Base.connection_db_config

#     # Set up the connection pool for the reading role
#     ActiveRecord::Base.connects_to(database: { reading: :test, writing: :test })
#   end

#   teardown do
#     # Restore the original connection configuration
#     ActiveRecord::Base.establish_connection(@original_db_config)
#   end

#   def test_run_report_returns_completed_status_with_results_when_successful
#     # Mock the query execution to return test results
#     mock_results = ActiveRecord::Result.new(%w[event count], [['update', 9918], ['destroy', 38], ['create', 44]])

#     ActiveRecord::Base.connection.stub(:exec_query, mock_results) do
#       result = ReportRunner.run_report(@report, @params)

#       assert_equal :completed, result[:status]
#       assert_equal mock_results.columns, result[:results].columns
#       assert_equal mock_results.rows, result[:results].rows
#       assert_equal 'Test Report - Start date: 2025-01-01', result[:page_title]
#     end
#   end

#   def test_run_report_returns_error_status_when_query_fails
#     ActiveRecord::Base.connection.stub(:exec_query, ->(_sql_query) { raise StandardError.new('Database error') }) do
#       result = ReportRunner.run_report(@report, @params)

#       assert_equal :error, result[:status]
#       assert_equal 'Database error', result[:error]
#     end
#   end

#   def test_run_report_returns_timeout_status_when_execution_takes_too_long
#     # Mock the timeout constant to avoid long test execution
#     original_timeout = ReportRunner::REPORT_TIMEOUT
#     ReportRunner.const_set(:REPORT_TIMEOUT, 0.1)
#     # Create a thread that never completes
#     Thread.stub(:new, Thread.new { sleep ReportRunner::REPORT_TIMEOUT + 1 }) do
#       result = ReportRunner.run_report(@report, @params)

#       assert_equal :timeout, result[:status]
#     end

#     ReportRunner.const_set(:REPORT_TIMEOUT, original_timeout)
#   end

#   def test_run_report_handles_multiple_parameter_sets
#     @params = ActionController::Parameters.new(
#       {
#         '0' => { 'start_date' => '2024-01-01' },
#         '1' => { 'start_date' => '2025-01-01' }
#       }
#     )

#     # Mock the query execution to return different results for each parameter set
#     combined_results = ActiveRecord::Result.new(
#       ['event', 'count (1)', 'count (2)', 'count Diff (1->2)', 'count Diff %(1->2)'],
#       [['update', 9918, 9918, 0.0, 0.0], ['destroy', 38, 38, 0.0, 0.0], ['create', 44, 44, 0.0, 0.0]]
#     )

#     # ActiveRecord::Base.connection.stubs(:exec_query).returns(mock_results1).then.returns(mock_results2)
#     ActiveRecordResultCombiner.stub(:combine_results, combined_results) do
#       result = ReportRunner.run_report(@report, @params)

#       assert_equal :completed, result[:status]
#       assert_equal combined_results, result[:results]
#       assert_equal 'Test Report - Start date: 2024-01-01, Start date: 2025-01-01', result[:page_title]
#     end
#   end

#   def test_run_report_handles_reports_without_parameters
#     @report.sql_query = 'SELECT * FROM users'

#     mock_results = ActiveRecord::Result.new(%w[id email], [[1, 'test@example.com']])
#     ActiveRecord::Base.connection.stub(:exec_query, mock_results) do
#       result = ReportRunner.run_report(@report, nil)

#       assert_equal :completed, result[:status]
#       assert_equal mock_results, result[:results]
#       assert_equal 'Test Report', result[:page_title]
#     end
#   end
# end
