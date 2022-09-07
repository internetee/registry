module Repp
  module V1
    class StatsController < BaseController
      api :get, '/repp/v1/stats/market_share_distribution'
      desc 'Get market share and distribution of registrars'
      param :q, Hash, required: true, desc: 'Period parameters for data' do
        param :end_date, String, required: true, desc: 'Period end date'
      end
      def market_share_distribution
        registrars = ::Registrar.where(test_registrar: false).joins(:domains)
                                .where(from_condition).where(to_condition)
        grouped = registrars.group(:name).count

        result = grouped.map do |key, value|
          hash = { name: key.strip, y: value }
          hash.merge!({ sliced: true, selected: true }) if current_user.registrar.name == key
          hash
        end
        render_success(data: result)
      end

      api :get, '/repp/v1/stats/market_share_growth_rate'
      desc 'Get market share and growth rate of registrars'
      param :q, Hash, required: true, desc: 'Period parameters for data' do
        param :end_date, String, required: true, desc: 'Period end date'
        param :compare_to_date, String, required: true, desc: 'Comparison date'
      end
      def market_share_growth_rate
        registrars = ::Registrar.where(test_registrar: false).joins(:domains)
                                .where(from_condition)

        domains_by_rar = registrars.where(to_condition).group(:name).count
        prev_domains_by_rar = registrars.where(compare_to_condition).group(:name).count

        set_zero_values!(domains_by_rar, prev_domains_by_rar)

        market_share_by_rar = calculate_market_share(domains_by_rar)
        prev_market_share_by_rar = calculate_market_share(prev_domains_by_rar)

        result = { prev_data: { name: search_params[:compare_to_date],
                                domains: serialize(prev_domains_by_rar),
                                market_share: serialize(prev_market_share_by_rar) },
                   data: { name: search_params[:end_date],
                           domains: serialize(domains_by_rar),
                           market_share: serialize(market_share_by_rar) } }
        render_success(data: result)
      end

      private

      def search_params
        params.permit(:q, q: %i[start_date end_date compare_to_date])
              .fetch(:q, {}) || {}
      end

      def from_condition
        return unless search_params[:start_date]

        "domains.created_at >= '#{to_date(search_params[:start_date])}'"
      end

      def to_condition
        return unless search_params[:end_date]

        "domains.created_at <= '#{to_date(search_params[:end_date]).end_of_month}'"
      end

      def compare_to_condition
        return unless search_params[:compare_to_date]

        "domains.created_at <= '#{to_date(search_params[:compare_to_date]).end_of_month}'"
      end

      def to_date(date_param)
        Date.strptime(date_param, '%m.%y')
      end

      def serialize(rars)
        rars.map { |key, value| [key, value] }
      end

      def set_zero_values!(cur, prev)
        cur_dup = cur.dup
        cur_dup.each_key do |k|
          cur_dup[k] = prev[k] || 0
        end
        prev.clear.merge!(cur_dup)
      end

      def calculate_market_share(domains_by_rar)
        sum = domains_by_rar.values.sum
        domains_by_rar.transform_values { |v| (v.to_f / sum * 100.0).round(1) }
      end
    end
  end
end
