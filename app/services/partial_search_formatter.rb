class PartialSearchFormatter
  def self.format(params)
    percentage = '%'
    search_params = params.deep_dup

    search_params.each do |key, value|
      next unless key.include?('matches') && value.present?

      value << percentage
    end

    search_params
  end
end
