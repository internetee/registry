module Repp
  module V1
    class RetainedDomainsController < ActionController::API
      def index
        domains = RetainedDomains.new(query_params)
        @response = { count: domains.count, domains: domains.to_jsonable }

        render json: @response
      end

      def query_params
        params.permit(:type)
      end
    end
  end
end
