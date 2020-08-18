module Repp
  module V1
    class RetainedDomainsController < ActionController::API
      def index
        domains = RetainedDomains.new(query_params)

        render json: { count: domains.count, domains: domains.to_jsonable }
      end

      def query_params
        params.permit(:type)
      end
    end
  end
end
