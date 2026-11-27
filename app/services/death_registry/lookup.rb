# frozen_string_literal: true

module DeathRegistry
  # Finds a death date by binary search in the file built by
  # DeathRegistry::FileBuilder, without loading the file into memory.
  #
  # Raises FileUnavailable when the file is missing, malformed or older than
  # max_age, so callers never mistake a missing file for "not deceased".
  class Lookup
    attr_reader :path, :max_age

    def initialize(path: DeathRegistry.file_path, max_age: DeathRegistry.max_file_age)
      @path = path
      @max_age = max_age
    end

    def available?
      File.file?(path) && File.mtime(path) >= max_age.ago && (File.size(path) % RECORD_SIZE).zero?
    end

    # Returns the death date as a Date, or nil if the ident is not in the file.
    def death_date(ident)
      raise FileUnavailable, "Death registry file #{path} is missing, stale or malformed" unless available?

      ident = ident.to_s
      return unless ident.match?(IDENT_FORMAT)

      File.open(path, 'rb') { |file| search(file, ident) }
    end

    def deceased?(ident)
      death_date(ident).present?
    end

    private

    def search(file, ident)
      low = 0
      high = (file.size / RECORD_SIZE) - 1

      while low <= high
        mid = (low + high) / 2
        file.seek(mid * RECORD_SIZE)
        record = file.read(RECORD_SIZE)

        case record[0, IDENT_LENGTH] <=> ident
        when 0 then return Date.iso8601(record[IDENT_LENGTH + 1, 10])
        when -1 then low = mid + 1
        else high = mid - 1
        end
      end

      nil
    end
  end
end
