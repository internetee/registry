# frozen_string_literal: true

require 'csv'

module DeathRegistry
  # Downloads the death open data CSVs and replaces the local lookup file.
  #
  # The new file is written next to the old one and renamed over it, so readers
  # see either the old or the new file, never a partial one. If a download fails
  # or yields suspiciously few records, the old file is kept.
  class FileBuilder
    OPEN_TIMEOUT = 30
    READ_TIMEOUT = 300
    DATE_FORMAT = /\A\d{4}-\d{2}-\d{2}\z/.freeze

    attr_reader :path, :source_urls, :min_records

    def initialize(path: DeathRegistry.file_path,
                   source_urls: DeathRegistry.source_urls,
                   min_records: DeathRegistry.min_records)
      @path = path
      @source_urls = source_urls
      @min_records = min_records
    end

    # Returns the number of records written.
    def call
      records = source_urls.flat_map { |url| with_download(url) { |file| parse(file) } }
      records = unique_by_ident(records.sort!)

      if records.size < min_records
        raise Error, "Death registry has only #{records.size} records, expected at least #{min_records}"
      end

      write_atomically(records)
      records.size
    end

    private

    def with_download(url)
      uri = URI.parse(url)

      Tempfile.create(['death_registry', '.csv'], binmode: true) do |file|
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https',
                                            open_timeout: OPEN_TIMEOUT,
                                            read_timeout: READ_TIMEOUT) do |http|
          http.request_get(uri.request_uri) do |response|
            raise Error, "Downloading #{url} failed: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

            response.read_body { |chunk| file.write(chunk) }
          end
        end

        file.flush
        file.rewind
        yield file
      end
    end

    # Rows without a valid ident or death date (the source uses "-" for
    # missing values) are skipped.
    def parse(file)
      records = []
      csv = CSV.new(file, col_sep: ';', headers: true, encoding: 'bom|utf-8')

      csv.each do |row|
        ident = row['isikukood'].to_s.strip
        death_date = row['surma_kp'].to_s.strip
        next unless ident.match?(IDENT_FORMAT) && death_date.match?(DATE_FORMAT)

        records << "#{ident};#{death_date}\n"
      end

      missing = %w[isikukood surma_kp] - Array(csv.headers)
      raise Error, "Death registry CSV is missing columns: #{missing.join(', ')}" if missing.any?

      records
    end

    # Records are sorted, so the earliest death date of a duplicated ident
    # comes first and is the one kept.
    def unique_by_ident(records)
      records.each_with_object([]) do |record, unique|
        unique << record unless unique.last&.start_with?(record[0, IDENT_LENGTH])
      end
    end

    def write_atomically(records)
      FileUtils.mkdir_p(File.dirname(path))
      tmp_path = "#{path}.#{Process.pid}.tmp"

      File.open(tmp_path, 'wb') do |file|
        records.each { |record| file.write(record) }
        file.fsync
      end

      File.rename(tmp_path, path)
    ensure
      FileUtils.rm_f(tmp_path) if tmp_path
    end
  end
end
