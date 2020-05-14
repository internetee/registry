module Repp
  module V1
    class RetainedDomainsController < ActionController::API
      def index
        domains = RetainedDomains.new

        render json: { count: domains.count, domains: domains.to_jsonable }
      end
    end
  end
end
