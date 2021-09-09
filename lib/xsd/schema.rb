module Xsd
  class Schema < ApplicationService
    SCHEMA_PATH = 'lib/schemas/'.freeze
    BASE_URL = 'https://epp.tld.ee/schema/'.freeze

    REGEX_PREFIX_WITH_DASH = /(?<prefix>\w+-\w+)-(?<version>\w.\w).xsd/
    REGEX_PREFIX_WITHOUT_DASH = /(?<prefix>\w+)-(?<version>\w.\w).xsd/

    PREFIXES = %w[
      domain-ee
      domain-eis
      all-ee
      changePoll
      contact
      contact-ee
      contact-eis
      eis
      epp
      epp-ee
      eppcom
      host
      secDNS
    ].freeze

    attr_reader :xsd_schemas, :for_prefix, :for_version

    def initialize(params)
      schema_path = params.fetch(:schema_path, SCHEMA_PATH)
      @for_prefix = params.fetch(:for_prefix)
      @for_version = params[:for_version] || '1.1'
      @xsd_schemas = Dir.entries(schema_path).select { |f| File.file? File.join(schema_path, f) }
    end

    def self.filename(*args, &block)
      new(*args, &block).call
    end

    def call
      filename = get_schema(for_prefix)
      BASE_URL + filename
    end

    private

    def get_schema(prefix)
      actual_schema = ''
      schemas = schemas_by_name[prefix]

      schemas.each do |schema|
        actual_schema = assigment_actual_version(schema)
        break unless actual_schema.empty?
      end

      actual_schema
    end

    def assigment_actual_version(schema)
      result = return_parsed_schema(schema)
      actual_schema = schema if result[:version] == @for_version

      actual_schema.to_s
    end

    def return_parsed_schema(data)
      res = data.to_s.match(REGEX_PREFIX_WITH_DASH)
      res = data.to_s.match(REGEX_PREFIX_WITHOUT_DASH) if res.nil?
      res
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
