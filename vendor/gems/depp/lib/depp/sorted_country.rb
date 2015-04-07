require 'countries'
require 'action_view'

class SortedCountry
  class << self
    include ActionView::Helpers

    def all_options(selected = nil)
      quick_options = options_for_select(quick_list + [['---','']], selected)  

      # no double select
      selected = quick_list.map{ |c| c.second }.include?(selected) ? '' : selected 

      all_options = options_for_select(all_sorted_truncated, selected)
      quick_options + all_options
    end

    private

    def quick_list
      @quick_list ||=
        [
          ['Estonia', 'EE'],
          ['Finland', 'FI'],
          ['Latvia', 'LV'],
          ['Lithuania', 'LT'],
          ['Russian Federation', 'RU'],
          ['Sweden', 'SE'],
          ['United States', 'US']
        ]
    end

    def all_sorted
      @all_sorted ||= Country.all.sort_by { |name, _code| name.first }
    end

    def all_sorted_truncated
      @all_sorted_truncated ||= 
        all_sorted.map { |name, code| [truncate(name, length: 26), code] }
    end
  end
end
