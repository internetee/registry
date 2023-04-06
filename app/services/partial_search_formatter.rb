class PartialSearchFormatter
  def self.format(params)
    search_params = params.deep_dup

    search_params.each do |key, value|
      next unless should_format?(key, value)

      search_params[key] = format_value(value)
    end

    search_params
  end

  def self.should_format?(key, value)
    key.include?('matches') && value.present?
  end

  def self.format_value(value)
    if value =~ /\A\*.*\*\z/
      value.gsub(/\A\*|\*\z/, '')
    else
      "%#{value}%"
    end
  end
end
