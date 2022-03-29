class PartialSearchFormatter
  def self.format(search_params)
    percentage = '%'

    search_params.each do |key, value|
      next unless key.include?('matches') && value.present?

      value.prepend(percentage).concat(percentage)
    end

    search_params
  end
end
