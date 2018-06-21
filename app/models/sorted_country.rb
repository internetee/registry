class SortedCountry
  class << self
    include ActionView::Helpers

    def all_options(selected = nil)
      quick_options = options_for_select(quick_list, selected: selected)

      # no double select
      selected = quick_list.map(&:second).include?(selected) ? '' : selected

      all_options = options_for_select([['---', '---']] + all_sorted_truncated,
                                       selected: selected, disabled: ['---'])
      quick_options + all_options
    end

    private

    def quick_list
      @quick_list ||=
        [
          %w[Estonia EE],
          %w[Finland FI],
          %w[Latvia LV],
          %w[Lithuania LT],
          ['Russian Federation', 'RU'],
          %w[Sweden SE],
          ['United States', 'US']
        ]
    end

    def all_sorted
      @all_sorted ||= Country.all.sort_by(&:name)
    end

    def all_sorted_truncated
      @all_sorted_truncated ||=
        all_sorted.map { |country| [country.name.truncate(26), country.alpha2] }
    end
  end
end
