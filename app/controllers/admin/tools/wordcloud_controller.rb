# frozen_string_literal: true

module Admin
  module Tools
    # Controller for the admin wordcloud generator tool that creates visual representations
    # of the most common words used in domain names
    class WordcloudController < BaseController # rubocop:disable Metrics/ClassLength
      WORDCLOUD_DIR = Rails.root.join('public', 'wordcloud')
      WORDCLOUD_IMAGE_PATH = WORDCLOUD_DIR.join('wordcloud.png')
      WORDCLOUD_CONFIG_PATH = WORDCLOUD_DIR.join('config.json')
      TOP_WORDS_PATH = WORDCLOUD_DIR.join('top_words.txt')

      before_action :authorize_admin
      before_action :clear_cache, only: :create
      before_action :ensure_wordcloud_dir, only: :create

      def index
        # Load configuration
        @config = load_wordcloud_config

        # Setup wordcloud data if image exists
        if File.exist?(WORDCLOUD_IMAGE_PATH)
          setup_wordcloud_data
        else
          @wordcloud_url = nil
        end
      end

      def create
        # Validate domains file
        if params[:domains_file].present?
          domains_file_path = process_uploaded_file(params[:domains_file])
          return redirect_to admin_tools_wordcloud_path if domains_file_path.nil?
        else
          flash[:alert] = I18n.t('admin.tools.wordcloud_no_file')
          return redirect_to admin_tools_wordcloud_path
        end

        # Collect and save configuration
        config = build_config_from_params
        File.write(WORDCLOUD_CONFIG_PATH, config.to_json)

        # Start the background job
        GenerateWordCloudJob.perform_later(domains_file_path.to_s, current_admin_user.id, config)
        redirect_to progress_admin_tools_wordcloud_path

      rescue StandardError => e
        logger.error "Error starting wordcloud generation: #{e.message}"
        flash[:alert] = "#{I18n.t('admin.tools.wordcloud_error')}: #{e.message}"
        redirect_to admin_tools_wordcloud_path
      end

      # GET /admin/tools/wordcloud/progress
      def progress
        @progress_key = "wordcloud_progress:#{current_admin_user.id}"
        @progress_data = Rails.cache.fetch(@progress_key) || { status: 'not_started', progress: 0 }
      end

      # GET /admin/tools/wordcloud/status
      def status
        progress_key = "wordcloud_progress:#{current_admin_user.id}"
        progress_data = Rails.cache.fetch(progress_key) || { status: 'not_started', progress: 0 }

        render json: progress_data
      end

      private

      def ensure_wordcloud_dir
        FileUtils.mkdir_p(WORDCLOUD_DIR) unless Dir.exist?(WORDCLOUD_DIR)
      end

      def process_uploaded_file(uploaded_file)
        # Create a persistent copy of the uploaded file
        persistent_file_path = Rails.root.join('tmp', "domains_#{Time.now.to_i}.csv")

        # Copy the file content to a persistent location
        FileUtils.cp(uploaded_file.tempfile.path, persistent_file_path)

        # Validate file has content
        if File.size(persistent_file_path).zero?
          File.delete(persistent_file_path)
          flash[:alert] = I18n.t('admin.tools.wordcloud_empty_file')
          return nil
        end

        persistent_file_path
      end

      def build_config_from_params
        # Base configuration
        config = {
          width: params[:width].presence || 800,
          height: params[:height].presence || 800,
          max_words: params[:max_words].presence || 500,
          background_color: params[:background_color].presence || 'white',
          min_word_length: params[:min_word_length].presence || 2,
          include_numbers: params[:include_numbers] == '1',
          batch_size: params[:batch_size].presence || 500,
          additional_prompt: params[:additional_prompt].presence || nil
        }

        # Process additional stopwords
        if params[:additional_stopwords].present?
          stopwords = params[:additional_stopwords].downcase.split(/[\s,]+/).reject(&:empty?)
          config[:additional_stopwords] = stopwords if stopwords.any?
        end

        # Process special terms
        if params[:special_terms].present?
          special_terms = params[:special_terms].split(/[\s,]+/).reject(&:empty?)
          config[:special_terms] = special_terms if special_terms.any?
        end

        config
      end

      def load_wordcloud_config
        if File.exist?(WORDCLOUD_CONFIG_PATH)
          begin
            JSON.parse(File.read(WORDCLOUD_CONFIG_PATH))
          rescue JSON::ParserError
            default_wordcloud_config
          end
        else
          default_wordcloud_config
        end
      end

      def setup_wordcloud_data
        # Add timestamp to prevent caching
        @wordcloud_url = "/wordcloud/wordcloud.png?t=#{File.mtime(WORDCLOUD_IMAGE_PATH).to_i}"

        # Get the file's modification time and convert to application timezone
        @wordcloud_generated_at = File.mtime(WORDCLOUD_IMAGE_PATH).in_time_zone(Time.zone)

        # Load top words
        load_top_words
      end

      def load_top_words
        return unless File.exist?(TOP_WORDS_PATH)

        @top_words = []
        File.readlines(TOP_WORDS_PATH).each do |line|
          if line =~ /^\d+\.\s+(\w+):\s+(\d+)$/
            @top_words << [$1, $2.to_i]
          end
        end
      end

      def default_wordcloud_config
        {
          'width' => 800,
          'height' => 800,
          'max_words' => 500,
          'background_color' => 'white',
          'additional_stopwords' => [],
          'include_numbers' => true,
          'min_word_length' => 2,
          'special_terms' => ['e-', 'i-', '2-', '3-', '4-', '.com', 'tr.ee', 'ai', 'web'],
          'batch_size' => 500
        }
      end

      def authorize_admin
        authorize! :access, :tools
      end

      def clear_cache
        Rails.cache.delete("wordcloud_progress:#{current_admin_user.id}")
      end
    end
  end
end
