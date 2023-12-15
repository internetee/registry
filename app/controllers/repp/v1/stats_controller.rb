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
        @date_from = to_date(search_params[:start_date] || '01.22')
        @date_compare_to = to_date(search_params[:compare_to_end_date]).end_of_month
        @date_compare_from = to_date(search_params[:compare_to_start_date] || '01.22')
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

      def domains_by_registrar(date_to, date_from)
        sql = <<-SQL
          SELECT
            registrar_id,
            SUM(domain_count) AS total_domain_count
          FROM (
            -- Count domains from the domains table, excluding those in created_domains
            SELECT
              registrar_id::text AS registrar_id,
              COUNT(*) AS domain_count
            FROM
              domains
            WHERE
              created_at >= :date_from
            GROUP BY
              registrar_id

            UNION ALL

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

            -- Query for 'update' events and count domains transferred to a new registrar only for domains in created_domains
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

            -- Query for 'update' events and count domains transferred from an old registrar only for domains in created_domains
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

            -- Query for 'destroy' events and count the number of domains destroyed associated with each registrar only for domains in created_domains
            SELECT
              (object_changes->'registrar_id'->>0)::text AS registrar_id,
              COUNT(*) AS domain_count
            FROM
                log_domains
            WHERE
                event = 'destroy'
                AND created_at > :date_to
            GROUP BY
                registrar_id

          ) AS combined
          GROUP BY
            registrar_id;
        SQL

        results = ActiveRecord::Base.connection.execute(
          ActiveRecord::Base.send(:sanitize_sql_array, [sql, date_from: date_from, date_to: date_to])
        ).each_with_object({}) do |row, hash|
          hash[row['registrar_id']] = row['total_domain_count'].to_i
        end

        results
      end

      # def domains_by_registrar(date_to, date_from)
      #   p 'Count the number of domains created by each registrar'
      #   sql = <<-SQL
      #     WITH created_domains AS (
      #       SELECT
      #         (object_changes->'registrar_id'->>1)::text AS registrar_id,
      #         (object_changes->'name'->>1)::text AS domain_name
      #       FROM
      #         log_domains
      #       WHERE
      #         event = 'create'
      #         AND created_at BETWEEN :date_from AND :date_to
      #     )
      #     SELECT
      #       registrar_id,
      #       SUM(domain_count) AS total_domain_count
      #     FROM (
      #       -- Count domains from created_domains
      #       SELECT
      #         registrar_id,
      #         COUNT(*) AS domain_count
      #       FROM
      #         created_domains
      #       GROUP BY
      #         registrar_id

      #       UNION ALL

      #       -- Query for 'update' events and count domains transferred to a new registrar only for domains in created_domains
      #       SELECT
      #         (object_changes->'registrar_id'->>1)::text AS registrar_id,
      #         COUNT(*) AS domain_count
      #       FROM
      #         log_domains
      #       WHERE
      #         event = 'update'
      #         AND object_changes->'registrar_id' IS NOT NULL
      #         AND (object->'name')::text IN (SELECT domain_name FROM created_domains)
      #         AND created_at BETWEEN :date_from AND :date_to
      #       GROUP BY
      #         registrar_id

      #       UNION ALL

      #       -- Query for 'update' events and count domains transferred from an old registrar only for domains in created_domains
      #       SELECT
      #         (object_changes->'registrar_id'->>0)::text AS registrar_id,
      #         COUNT(*) * -1 AS domain_count
      #       FROM
      #         log_domains
      #       WHERE
      #         event = 'update'
      #         AND object_changes->'registrar_id' IS NOT NULL
      #         AND (object->'name')::text IN (SELECT domain_name FROM created_domains)
      #         AND created_at BETWEEN :date_from AND :date_to
      #       GROUP BY
      #         registrar_id

      #       UNION ALL

      #       -- Query for 'destroy' events and count the number of domains destroyed associated with each registrar only for domains in created_domains
      #       SELECT
      #         (object_changes->'registrar_id'->>0)::text AS registrar_id,
      #         COUNT(*) * -1 AS domain_count
      #       FROM
      #           log_domains
      #       WHERE
      #           event = 'destroy'
      #           AND (object_changes->'name'->>0)::text IN (SELECT domain_name FROM created_domains)
      #           AND created_at BETWEEN :date_from AND :date_to
      #       GROUP BY
      #           registrar_id

      #       UNION ALL

      #       -- Count domains from the domains table, excluding those in created_domains
      #       SELECT
      #         registrar_id::text AS registrar_id,
      #         COUNT(*) AS domain_count
      #       FROM
      #         domains
      #       WHERE
      #         name NOT IN (SELECT domain_name FROM created_domains)
      #         AND created_at BETWEEN :date_from AND :date_to
      #       GROUP BY
      #         registrar_id

      #     ) AS combined
      #     GROUP BY
      #       registrar_id;
      #   SQL

      #   results = ActiveRecord::Base.connection.execute(
      #     ActiveRecord::Base.send(:sanitize_sql_array, [sql, date_from: date_from, date_to: date_to])
      #   ).each_with_object({}) do |row, hash|
      #     hash[row['registrar_id']] = row['total_domain_count'].to_i
      #   end

      #   p results
      # end

      # def domains_by_registrar(date_to, date_from)
      #   log_domains_del = log_domains(event: 'destroy', date_to: date_to, date_from: date_from)
      #   log_domains_trans = log_domains(event: 'update', date_to: date_to, date_from: date_from)
      #   logged_domains = log_domains_trans.map { |ld| ld.object['name'] } +
      #                    log_domains_del.map { |ld| ld.object['name'] }
      #   domains_grouped = ::Domain.where('created_at <= ? AND created_at >= ?', date_to, date_from)
      #                             .where.not(name: logged_domains.uniq)
      #                             .group(:registrar_id).count.stringify_keys

      #   summarize([group(log_domains_del), group(log_domains_trans), domains_grouped])
      # end

      # def domains_by_registrar(date_to, date_from)
      #   domain_versions = ::Version::DomainVersion.where('object_changes IS NOT NULL')
      #                                             .where('created_at >= ? AND created_at <= ?', date_from, date_to)
      #                                             .select(:event, :object, :object_changes)
      #   registrar_counts = Hash.new(0)
      #   processed_domains = []
      #   Rails.logger.info "Processing total #{domain_versions.size} log_domain records"
      #   domain_versions.each do |v|
      #     registrar_ids = v.object_changes['registrar_id']
      #     next if registrar_ids.nil? || registrar_ids.empty?

      #     case v.event
      #     when 'create'
      #       processed_domains << v.object_changes['name'][1]
      #       registrar_counts[registrar_ids[1].to_s] += 1
      #     when 'update'
      #       if processed_domains.include?(v.object['name'])
      #         registrar_counts[registrar_ids[0].to_s] -= 1
      #         registrar_counts[registrar_ids[1].to_s] += 1
      #       else
      #         registrar_counts[registrar_ids[1].to_s] += 1
      #         processed_domains << v.object['name']
      #       end
      #     when 'destroy'
      #       registrar_counts[registrar_ids[0].to_s] -= 1
      #     end
      #   end

      #   current_domains_grouped = ::Domain.where('created_at <= ? AND created_at >= ?', date_to, date_from)
      #                                     .where.not(name: processed_domains.uniq)
      #                                     .group(:registrar_id).count.stringify_keys

      #   summarize([registrar_counts, current_domains_grouped])
      # end

      def summarize(arr)
        arr.inject { |memo, el| memo.merge(el) { |_, old_v, new_v| old_v + new_v } }
      end

      def log_domains(event:, date_to:, date_from:)
        domain_version = ::Version::DomainVersion.where(event: event)
        domain_version.where!("object_changes ->> 'registrar_id' IS NOT NULL") if event == 'update'
        domain_version.where('created_at > ?', date_to)
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
                                        .reduce({}, :merge)
      end

      def serialize_distribution_result(result)
        result.map do |key, value|
          next unless registrar_names.key?(key)

          name = registrar_names[key]
          hash = { name: name, y: value }
          hash.merge!({ sliced: true, selected: true }) if current_user.registrar.name == name
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
