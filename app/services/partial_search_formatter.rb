class PartialSearchFormatter
  def self.format(params)
    search_params = params.deep_dup

    search_params.each do |key, value|
      next unless key.include?('matches') && value.present?

      value << '%'
    end

    search_params
  end
end
