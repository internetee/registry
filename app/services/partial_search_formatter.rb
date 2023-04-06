class PartialSearchFormatter
  def self.format(params)
    search_params = params.deep_dup

    search_params.each do |key, value|
      next unless key.include?('matches') && value.present?

      if value =~ /\A\*.*\*\z/
        search_params[key] = value.gsub(/\A\*|\*\z/, '')
      else
        search_params[key] = "%#{value}%"
      end
    end

    search_params
  end
end
