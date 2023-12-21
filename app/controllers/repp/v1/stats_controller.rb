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
        domains_by_rar = domains_by_registrar(@date_to)
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
        domains_by_rar = domains_by_registrar(@date_to)
        prev_domains_by_rar = domains_by_registrar(@date_compare_to)

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
        params.permit(:q, q: %i[end_date compare_to_end_date])
              .fetch(:q, {}) || {}
      end

      def set_date_params
        @date_to = to_date(search_params[:end_date]).end_of_month
        @date_compare_to = to_date(search_params[:compare_to_end_date]).end_of_month
      end

      def to_date(date_param)
        return Time.zone.today if date_param.blank?

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

      # rubocop:disable Metrics/MethodLength
      def domains_by_registrar(date_to)
        sql = <<-SQL
          SELECT
            registrar_id,
            SUM(domain_count) AS total_domain_count
          FROM (
            -- Query for current domains for each registrar
            SELECT
              registrar_id::text AS registrar_id,
              COUNT(*) AS domain_count
            FROM
              domains
            GROUP BY
              registrar_id

            UNION ALL

            -- Query for 'create' events and count domains created by registrar
            SELECT
              (object_changes->'registrar_id'->>1)::text AS registrar_id,
              COUNT(*) * -1 AS domain_count
            FROM
              log_domains
            WHERE
              event = 'create'
              AND created_at > :date_to
            GROUP BY
              registrar_id

            UNION ALL

            -- Query for 'update' events and count domains transferred to a new registrar
            SELECT
              (object_changes->'registrar_id'->>1)::text AS registrar_id,
              COUNT(*) * -1 AS domain_count
            FROM
              log_domains
            WHERE
              event = 'update'
              AND object_changes->'registrar_id' IS NOT NULL
              AND created_at > :date_to
            GROUP BY
              registrar_id

            UNION ALL

            -- Query for 'update' events and count domains transferred from an old registrar
            SELECT
              (object_changes->'registrar_id'->>0)::text AS registrar_id,
              COUNT(*) AS domain_count
            FROM
              log_domains
            WHERE
              event = 'update'
              AND object_changes->'registrar_id' IS NOT NULL
              AND created_at > :date_to
            GROUP BY
              registrar_id

            UNION ALL

            -- Query for 'destroy' events and count the number of domains destroyed associated with each registrar
            SELECT
              (object_changes->'registrar_id'->>0)::text AS registrar_id,
              COUNT(*) AS domain_count
            FROM
                log_domains
            WHERE
                event = 'destroy'
                AND object_changes->'registrar_id' IS NOT NULL
                AND created_at > :date_to
            GROUP BY
                registrar_id

            UNION ALL

            -- Query for 'destroy' events and count the number of domains destroyed associated with each registrar
            SELECT
              (object->'registrar_id')::text AS registrar_id,
              COUNT(*) AS domain_count
            FROM
                log_domains
            WHERE
                event = 'destroy'
                AND object_changes IS NULL
                AND created_at > :date_to
            GROUP BY
                registrar_id

          ) AS combined
          GROUP BY
            registrar_id;
        SQL

        ActiveRecord::Base.connection.execute(
          ActiveRecord::Base.send(:sanitize_sql_array, [sql, { date_to: date_to }])
        ).each_with_object({}) do |row, hash|
          hash[row['registrar_id']] = row['total_domain_count'].to_i
        end
      end
      # rubocop:enable Metrics/MethodLength

      def registrar_names
        @registrar_names ||= ::Registrar.where(test_registrar: false)
                                        .map { |r| { "#{r.id}": r.name }.with_indifferent_access }
                                        .reduce({}, :merge)
      end

      def serialize_distribution_result(result)
        result.map do |key, value|
          next unless registrar_names.key?(key)

          name = registrar_names[key]
          hash = { name: name, y: value }
          if current_user.registrar.name == name
            hash[:sliced] = true
            hash[:selected] = true
          end
          hash
        end.compact
      end

      def serialize_growth_rate_result(result)
        result.map do |key, value|
          next unless registrar_names.key?(key)

          name = registrar_names[key]
          [name, value]
        end.compact
      end
    end
  end
end
