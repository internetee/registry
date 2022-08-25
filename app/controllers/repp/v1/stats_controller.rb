module Repp
  module V1
    class StatsController < BaseController
      api :get, '/repp/v1/stats/market_share'
      desc 'Get market share and distribution of registrars'
      def market_share
        registrars = ::Registrar.where(test_registrar: false).joins(:domains)
        registrars = registrars.where(from_condition).where(to_condition)
        grouped = registrars.group(:name).count

        result = grouped.map do |key, value|
          hash = { name: key.strip, y: value }
          hash.merge!({ sliced: true, selected: true }) if current_user.registrar.name == key
          hash
        end
        render_success(data: result)
      end

      private

      def search_params
        params.permit(:q, q: %i[start_date end_date]).fetch(:q, {}) || {}
      end

      def from_condition
        return unless search_params[:start_date]

        "domains.created_at >= '#{Date.strptime(search_params[:start_date], '%m.%y')}'"
      end

      def to_condition
        return unless search_params[:end_date]

        "domains.created_at <= '#{Date.strptime(search_params[:end_date], '%m.%y').end_of_month}'"
      end
    end
  end
end