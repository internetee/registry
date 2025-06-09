class PartialSearchFormatter
  def self.format(params)
    search_params = params.deep_dup

    search_params.each do |key, value|
      next unless should_format?(key, value)

      search_params[key] = format_value(value, key)
    end

    search_params
  end

  def self.should_format?(key, value)
    key.include?('matches') && value.present?
  end

  def self.format_value(value, key)
    if value =~ /\A\*.*\*\z/
      value.gsub(/\A\*|\*\z/, '')
    elsif key.include?('ident')
      # For contact identifiers, return array of values
      parts = value.split('-')
      parts.map { |part| "%#{part}%" }
    else
      "%#{value}%"
    end
  end
end
