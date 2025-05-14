# Use Open3 to capture output in real-time
require 'open3'

# Background job that generates a wordcloud image from domain names
# using an external Python script with progress tracking
class GenerateWordCloudJob < ApplicationJob
  def perform(domains_file_path, user_id, config = {})
    @domains_file_path = domains_file_path
    @user_id = user_id
    @config = config
    @progress_key = "wordcloud_progress:#{user_id}"
    @wordcloud_dir = Rails.root.join('public', 'wordcloud')
    @config_file_path = nil

    initialize_progress

    begin
      setup_environment
      run_wordcloud_script
    rescue StandardError => e
      handle_error(e)
    ensure
      cleanup
    end
  end

  private

  def initialize_progress
    Rails.cache.write(@progress_key, { status: 'processing', progress: 0 })
  end

  def setup_environment
    # Ensure the wordcloud directory exists
    FileUtils.mkdir_p(@wordcloud_dir) unless Dir.exist?(@wordcloud_dir)

    # Create a config file for the Python script
    @config_file_path = Rails.root.join(@wordcloud_dir, "wordcloud_config_#{Time.now.to_i}.json")
    File.write(@config_file_path, @config.to_json)

    # Setup Python script
    @script_path = Rails.root.join('lib', 'wordcloud', 'generate_wordcloud.py')
    FileUtils.chmod('+x', @script_path) unless File.executable?(@script_path)
  end

  def run_wordcloud_script
    python_executable = ENV.fetch('PYTHON_EXECUTABLE', 'python3')
    env = { 'PYTHONIOENCODING' => 'utf-8', 'PYTHONUNBUFFERED' => '1' }

    Open3.popen2e(env, python_executable, @script_path.to_s, @domains_file_path,
                 @wordcloud_dir.to_s, @config_file_path.to_s) do |stdin, stdout_err, wait_thr|
      stdin.close
      process_script_output(stdout_err, wait_thr)
    end
  end

  def process_script_output(stdout_err, wait_thr)
    # Process output line by line
    while line = stdout_err.gets
      update_progress_from_output(line)
      Rails.logger.info("WordCloud: #{line.strip}")
    end

    # Process exit status
    handle_exit_status(wait_thr.value)
  end

  def update_progress_from_output(line)
    case line
    when %r{Processing batch (\d+)/(\d+)}
      current, total = $1.to_i, $2.to_i
      progress = ((current.to_f / total) * 80).round
      update_progress(progress)
    when /Total estimated cost/
      update_progress(80)
    when /Generating word cloud/
      update_progress(90)
    end
  end

  def update_progress(value, status: 'processing')
    Rails.cache.write(@progress_key, { status: status, progress: value })
  end

  def handle_exit_status(exit_status)
    if exit_status.success?
      update_progress(100, status: 'completed')
    else
      Rails.cache.write(
        @progress_key,
        {
          status: 'failed',
          progress: 0,
          error: "Process failed with status #{exit_status.exitstatus}"
        }
      )
    end
  end

  def handle_error(exception)
    Rails.logger.error("Error in WordCloud job: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))
    Rails.cache.write(
      @progress_key,
      {
        status: 'failed',
        progress: 0,
        error: exception.message
      }
    )
  end

  def cleanup
    File.delete(@config_file_path) if @config_file_path && File.exist?(@config_file_path)
  end
end
