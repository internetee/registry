module Api
  module V1
    class AuctionsController < BaseController
      before_action :authenticate, except: :index

      def index
        render json: Auction.started.map { |auction| serializable_hash(auction) }
      end

      def show
        auction = Auction.find_by!(uuid: params[:uuid])
        render json: serializable_hash(auction)
      end

      def update
        auction = Auction.find_by!(uuid: params[:uuid])

        case params[:status]
        when Auction.statuses[:awaiting_payment]
          auction.awaiting_payment!
        when Auction.statuses[:no_bids]
          auction.mark_as_no_bids
        when Auction.statuses[:payment_received]
          auction.mark_as_payment_received
        when Auction.statuses[:payment_not_received]
          auction.mark_as_payment_not_received
        when Auction.statuses[:domain_not_registered]
          auction.mark_as_domain_not_registered
        else
          raise "Invalid status #{params[:status]}"
        end

        if auction.payment_not_received? || auction.domain_not_registered?
          update_whois_from_auction(Auction.pending(auction.domain))
        else
          update_whois_from_auction(auction)
        end

        render json: serializable_hash_for_update_action(auction)
      end

      private

      def serializable_hash(auction)
        { id: auction.uuid, domain: auction.domain, status: auction.status }
      end

      def serializable_hash_for_update_action(auction)
        hash = serializable_hash(auction)
        hash[:registration_code] = auction.registration_code if auction.payment_received?
        hash
      end

      def update_whois_from_auction(auction)
        whois_record = Whois::Record.find_by!(name: auction.domain)
        whois_record.update_from_auction(auction)
      end
    end
  end
end
