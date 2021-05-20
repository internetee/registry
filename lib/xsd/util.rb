module Xsd
  class Util < ApplicationService
    SCHEMA_PATH = 'lib/schemas/'.freeze

    attr_reader :xsd_schemas, :for_prefix

    def initialize(params)
      schema_path = params.fetch(:schema_path, SCHEMA_PATH)
      @for_prefix = params.fetch(:for_prefix)
      @xsd_schemas = Dir.entries(schema_path).select { |f| File.file? File.join(schema_path, f) }
    end

    def call
      latest(for_prefix)
    end

    private

    def latest(prefix)
      schemas_by_name[prefix].last
    end

    def basename(filename)
      File.basename(filename, '.xsd')
    end

    def prefix(filename)
      regex = /([a-zA-Z]+-?[a-zA-Z]+)/

      basename(filename).match(regex)[0]
    end

    def prefixes
      xsd_schemas.map { |filename| prefix(filename) }.uniq
    end

    def schemas_by_name
      prefixes.each_with_object({}) do |prefix, hash|
        hash[prefix] = xsd_schemas.select { |filename| prefix_check(prefix, filename) }.uniq.sort
      end
    end

    def prefix_check(prefix, filename)
      version_regex = /\-\d+\S\d+/
      (filename.include? prefix) && (filename.sub(prefix, '')[0, 4] =~ version_regex)
    end
  end
end
