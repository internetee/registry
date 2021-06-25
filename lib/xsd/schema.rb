module Xsd
  class Schema < ApplicationService
    SCHEMA_PATH = 'lib/schemas/'.freeze
    BASE_URL = 'https://epp.tld.ee/schema/'.freeze

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
			@for_version = params.fetch(:for_version, '1.1')
      @xsd_schemas = Dir.entries(schema_path).select { |f| File.file? File.join(schema_path, f) }
    end

    def self.filename(*args, &block)
      new(*args, &block).call
    end

    def call
      filename = latest(for_prefix)
      BASE_URL + filename
    end

    private

		# xml = response.gsub!(/(?<=>)(.*?)(?=<)/, &:strip)
		# xml.to_s.match(/xmlns:domain=\"https:\/\/epp.tld.ee\/schema\/(?<prefix>\w+-\w+)-(?<version>\w.\w).xsd/)
		# The prefix and version of the response are returned are these variants - res[:prefix] res[:version]
	
    def latest(prefix)
      schemas = schemas_by_name[prefix]

			actual_schema = ''

			schemas.each do |schema|
				result = return_some(schema)

				if result[:version] == @for_version
					actual_schema = schema
				end

				if result[:prefix] == 'epp-ee'
					actual_schema = 'epp-ee-1.0.xsd'
				end

					if result[:prefix] == 'eis'
					actual_schema = 'eis-1.0.xsd'
				end
			end

			actual_schema
    end

		def return_some(data)
			res = data.to_s.match(/(?<prefix>\w+-\w+)-(?<version>\w.\w).xsd/)

			res = data.to_s.match(/(?<prefix>\w+)-(?<version>\w.\w).xsd/) if res.nil?

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
