# frozen_string_literal: true

# Local copy of the Population Register death open data
# (https://andmed.eesti.ee/datasets/surmaandmed), reduced to a sorted file of
# Estonian personal identity codes and death dates.
module DeathRegistry
  class Error < StandardError; end
  class FileUnavailable < Error; end

  DEFAULT_SOURCE_URLS = %w[
    https://opendata.smit.ee/etl/rahvastik/surmaandmed_1926_kuni_eelmise_aasta_lopuni.csv
    https://opendata.smit.ee/etl/rahvastik/surmaandmed_jooksev_aasta.csv
  ].freeze
  DEFAULT_MAX_FILE_AGE_DAYS = 8
  DEFAULT_MIN_RECORDS = 100_000

  # Every line is "<11-digit ident>;<YYYY-MM-DD>\n", so a record can be read by
  # seeking to index * RECORD_SIZE.
  IDENT_LENGTH = 11
  RECORD_SIZE = IDENT_LENGTH + 1 + 10 + 1
  IDENT_FORMAT = /\A\d{#{IDENT_LENGTH}}\z/.freeze

  module_function

  def file_path
    ENV['death_registry_file_path'].presence ||
      Rails.root.join('tmp', 'death_registry', 'deaths.txt').to_s
  end

  def source_urls
    ENV['death_registry_source_urls'].presence&.split(',')&.map(&:strip) || DEFAULT_SOURCE_URLS
  end

  def max_file_age
    (ENV['death_registry_max_file_age_days'].presence || DEFAULT_MAX_FILE_AGE_DAYS).to_i.days
  end

  def min_records
    (ENV['death_registry_min_records'].presence || DEFAULT_MIN_RECORDS).to_i
  end
end
