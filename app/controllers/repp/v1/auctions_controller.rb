module Repp
  module V1
    class AuctionsController < ActionController::API
      def index
        auctions = Auction.started
        @response = { count: auctions.count, auctions: auctions_to_json(auctions) }

        render json: @response
      end

      private

      def auctions_to_json(auctions)
        auctions.map do |e|
          {
            domain_name: e.domain,
            punycode_domain_name: SimpleIDN.to_ascii(e.domain),
          }
        end
      end
    end
  end
end
