module Repp
  module V1
    class StatsController < BaseController
      api :get, '/repp/v1/stats/market_share_distribution'
      desc 'Get market share and distribution of registrars'
      param :q, Hash, required: true, desc: 'Period parameters for data' do
        param :end_date, String, required: true, desc: 'Period end date'
      end
      def market_share_distribution
        date_to = to_date(search_params[:end_date]).end_of_month
        date_from = to_date(search_params[:start_date] || '01.1991')
        log_domains_del = ::Version::DomainVersion.where('event = ? AND created_at > ?' \
                                                         "AND object ->> 'created_at' <= ?" \
                                                         "AND object ->> 'created_at' >= ?",
                                                         'destroy', date_to, date_to, date_from)
                                                  .group("object ->> 'registrar_id'").count

        log_domains_trans = ::Version::DomainVersion.where('event = ? AND created_at > ?' \
                                                           "AND object ->> 'created_at' <= ?" \
                                                           "AND object ->> 'created_at' >= ?" \
                                                           "AND object_changes ->> 'registrar_id' IS NOT NULL",
                                                           'update', date_to, date_to, date_from)

        log_domains_trans_grouped = log_domains_trans.group("object ->> 'registrar_id'")
                                                     .count

        domains = ::Domain.where(from_condition)
                          .where(to_condition)
                          .where.not(name: log_domains_trans.map { |ld| ld.object['name'] })
                          .group(:registrar_id).count.stringify_keys

        grouped = summarize([log_domains_del, log_domains_trans_grouped, domains])

        registrar_names = ::Registrar.where(test_registrar: false)
                                     .map { |r| { "#{r.id}": r.name }.with_indifferent_access }
                                     .inject(:merge)

        result = grouped.map do |key, value|
          next unless registrar_names.key?(key)

          name = registrar_names[key]
          hash = { name: registrar_names[key], y: value }
          hash.merge!({ sliced: true, selected: true }) if current_user.registrar.name == name
          hash
        end

        render_success(data: result)
      end

      # rubocop:disable Metrics/MethodLength
      api :get, '/repp/v1/stats/market_share_growth_rate'
      desc 'Get market share and growth rate of registrars'
      param :q, Hash, required: true, desc: 'Period parameters for data' do
        param :end_date, String, required: true, desc: 'Period end date'
        param :compare_to_date, String, required: true, desc: 'Comparison date'
      end
      def market_share_growth_rate
        registrars = ::Registrar.where(test_registrar: false).joins(:domains)

        domains_by_rar = registrars.where(from_condition).where(to_condition).group(:name).count
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
      # rubocop:enable Metrics/MethodLength

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
        return if date_param.blank?

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
        return domains_by_rar if sum.zero?

        domains_by_rar.transform_values do |v|
          value = v.to_f / sum * 100.0
          value < 0.1 ? value.round(3) : value.round(1)
        end
      end

      def summarize(arr)
        arr.inject { |memo, el| memo.merge(el) { |_, old_v, new_v| old_v + new_v } }
      end
    end
  end
end
