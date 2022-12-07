module Repp
  module V1
    class StatsController < BaseController # rubocop:disable Metrics/ClassLength
      before_action :set_date_params

      api :get, '/repp/v1/stats/market_share_distribution'
      desc 'Get market share and distribution of registrars'
      param :q, Hash, required: true, desc: 'Period parameters for data' do
        param :end_date, String, required: true, desc: 'Period end date'
      end
      def market_share_distribution
        domains_by_rar = domains_by_registrar(@date_to, @date_from)
        result = serialize_distribution_result(domains_by_rar)
        render_success(data: result)
      end

      # rubocop:disable Metrics/MethodLength
      api :get, '/repp/v1/stats/market_share_growth_rate'
      desc 'Get market share and growth rate of registrars'
      param :q, Hash, required: true, desc: 'Period parameters for data' do
        param :end_date, String, required: true, desc: 'Period end date'
        param :compare_to_end_date, String, required: true, desc: 'Comparison date'
      end
      def market_share_growth_rate
        domains_by_rar = domains_by_registrar(@date_to, @date_from)
        prev_domains_by_rar = domains_by_registrar(@date_compare_to, @date_compare_from)

        set_zero_values!(domains_by_rar, prev_domains_by_rar)

        market_share_by_rar = calculate_market_share(domains_by_rar)
        prev_market_share_by_rar = calculate_market_share(prev_domains_by_rar)

        result = { prev_data: { name: search_params[:compare_to_end_date],
                                domains: serialize_growth_rate_result(prev_domains_by_rar),
                                market_share: serialize_growth_rate_result(prev_market_share_by_rar) },
                   data: { name: search_params[:end_date],
                           domains: serialize_growth_rate_result(domains_by_rar),
                           market_share: serialize_growth_rate_result(market_share_by_rar) } }
        render_success(data: result)
      end
      # rubocop:enable Metrics/MethodLength

      private

      def search_params
        params.permit(:q, q: %i[start_date end_date compare_to_end_date compare_to_start_date])
              .fetch(:q, {}) || {}
      end

      def set_date_params
        @date_to = to_date(search_params[:end_date]).end_of_month
        @date_from = to_date(search_params[:start_date] || '01.05')
        @date_compare_to = to_date(search_params[:compare_to_end_date]).end_of_month
        @date_compare_from = to_date(search_params[:compare_to_start_date] || '01.05')
      end

      def to_date(date_param)
        return if date_param.blank?

        Date.strptime(date_param, '%m.%y')
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

      def domains_by_registrar(date_to, date_from)
        log_domains_del = log_domains(event: 'destroy', date_to: date_to, date_from: date_from)
        log_domains_trans = log_domains(event: 'update', date_to: date_to, date_from: date_from)
        logged_domains = log_domains_trans.map { |ld| ld.object['name'] } +
                         log_domains_del.map { |ld| ld.object['name'] }
        domains_grouped = ::Domain.where('created_at <= ? AND created_at >= ?', date_to, date_from)
                                  .where.not(name: logged_domains.uniq)
                                  .group(:registrar_id).count.stringify_keys
        summarize([group(log_domains_del), group(log_domains_trans), domains_grouped])
      end

      def summarize(arr)
        arr.inject { |memo, el| memo.merge(el) { |_, old_v, new_v| old_v + new_v } }
      end

      def log_domains(event:, date_to:, date_from:)
        domains = ::Version::DomainVersion.where(event: event)
        domains.where!("object_changes ->> 'registrar_id' IS NOT NULL") if event == 'update'
        domains.where('created_at > ?', date_to)
               .where("object ->> 'created_at' <= ?", date_to)
               .where("object ->> 'created_at' >= ?", date_from)
               .select("DISTINCT ON (object ->> 'name') object, created_at")
               .order(Arel.sql("object ->> 'name', created_at desc"))
      end

      def group(domains)
        domains.group_by { |ld| ld.object['registrar_id'].to_s }
               .transform_values(&:count)
      end

      def registrar_names
        @registrar_names ||= ::Registrar.where(test_registrar: false)
                                        .map { |r| { "#{r.id}": r.name }.with_indifferent_access }
                                        .inject(:merge)
      end

      def serialize_distribution_result(grouped)
        grouped.map do |key, value|
          next unless registrar_names.key?(key)

          name = registrar_names[key]
          hash = { name: registrar_names[key], y: value }
          hash.merge!({ sliced: true, selected: true }) if current_user.registrar.name == name
          hash
        end
      end

      def serialize_growth_rate_result(grouped)
        grouped.map do |key, value|
          next unless registrar_names.key?(key)

          name = registrar_names[key]
          [name, value]
        end
      end
    end
  end
end
