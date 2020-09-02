module Repp
  module V1
    class AuctionsController < ActionController::API
      def index
        auctions = Auction.started

        render json: { count: auctions.count,
                       auctions: auctions_to_json(auctions) }
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
