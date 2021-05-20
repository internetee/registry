class XsdUtil
  SCHEMA_PATH = 'lib/schemas/'.freeze

  def initialise(schema_path = SCHEMA_PATH)
    @schema_path = schema_path
  end

  def xsd_schemas
    @xsd_schemas ||= Dir.entries(SCHEMA_PATH)
                        .select { |f| File.file? File.join(SCHEMA_PATH, f) }
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
      hash[prefix] = xsd_schemas.select { |filename| filename.include? prefix }.uniq.sort
    end
  end

  def latest(prefix)
    schemas_by_name[prefix].last
  end
end
