# Use Open3 to capture output in real-time
require 'open3'

class GenerateWordCloudJob < ApplicationJob
  def perform(domains_file_path, user_id, config = {})
    # Set up progress tracking
    progress_key = "wordcloud_progress:#{user_id}"
    Rails.cache.write(progress_key, { status: 'processing', progress: 0 })

    begin
      # Ensure the wordcloud directory exists
      wordcloud_dir = Rails.root.join('public', 'wordcloud')
      FileUtils.mkdir_p(wordcloud_dir) unless Dir.exist?(wordcloud_dir)

      # Setup Python environment
      python_executable = ENV.fetch('PYTHON_EXECUTABLE', 'python3')
      script_path = Rails.root.join('lib', 'wordcloud', 'generate_wordcloud.py')

      # Create a config file for the Python script
      config_file_path = Rails.root.join(wordcloud_dir, "wordcloud_config_#{Time.now.to_i}.json")
      File.write(config_file_path, config.to_json)

      # Set environment variables to ensure proper encoding
      env = { 'PYTHONIOENCODING' => 'utf-8', 'PYTHONUNBUFFERED' => '1' }

      # Debug information
      # Rails.logger.info("Python executable: #{python_executable}")
      # Rails.logger.info("Script path: #{script_path}")
      # Rails.logger.info("Domains file: #{domains_file_path}")
      # Rails.logger.info("Output directory: #{wordcloud_dir}")

      # Check if files exist
      # Rails.logger.info("Script exists: #{File.exist?(script_path)}")
      # Rails.logger.info("Domains file exists: #{File.exist?(domains_file_path)}")

      # Make script executable
      FileUtils.chmod('+x', script_path) unless File.executable?(script_path)

      Open3.popen2e(env, python_executable, script_path.to_s, domains_file_path, wordcloud_dir.to_s, config_file_path.to_s) do |stdin, stdout_err, wait_thr|
        # Close stdin since we don't need it
        stdin.close

        # Process output line by line
        while line = stdout_err.gets
          # Parse progress from Python script output
          if line =~ /Processing batch (\d+)\/(\d+)/
            current = $1.to_i
            total = $2.to_i
            progress = ((current.to_f / total) * 80).round
            Rails.cache.write(progress_key, { status: 'processing', progress: progress })
          elsif line =~ /Total estimated cost/
            # Update when word extraction is complete
            Rails.cache.write(progress_key, { status: 'processing', progress: 80 })
          elsif line =~ /Generating word cloud/
            # Update when word cloud generation starts
            Rails.cache.write(progress_key, { status: 'processing', progress: 90 })
          end

          # Log output for debugging
          Rails.logger.info("WordCloud: #{line.strip}")
        end

        # Check if the process was successful
        exit_status = wait_thr.value
        if exit_status.success?
          Rails.cache.write(progress_key, { status: 'completed', progress: 100 })
        else
          Rails.cache.write(progress_key, {
            status: 'failed',
            progress: 0,
            error: "Process failed with status #{exit_status.exitstatus}"
          })
        end
      end

    rescue => e
      Rails.logger.error("Error in WordCloud job: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      Rails.cache.write(progress_key, { status: 'failed', progress: 0, error: e.message })
    ensure
      # Clean up the config file
      File.delete(config_file_path) if File.exist?(config_file_path)
    end
  end
end

