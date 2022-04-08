module Admin
  class AuctionsController < BaseController
    load_and_authorize_resource

    def index
      params[:q] ||= {}

      @auctions = Auction.with_status(params[:statuses_contains])

      normalize_search_parameters do
        @q = @auctions.ransack(PartialSearchFormatter.format(params[:q]))
        @auctions = @q.result.page(params[:page])
      end

      @auctions = @auctions.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/auctions/index', 'auctions')
    end

    def update

      redirect_to admin_auctions_path
    end

    private

    def normalize_search_parameters
      ca_cache = params[:q][:valid_to_lteq]
      begin
        end_time = params[:q][:valid_to_lteq].try(:to_date)
        params[:q][:valid_to_lteq] = end_time.try(:end_of_day)
      rescue
        logger.warn('Invalid date')
      end

      yield

      params[:q][:valid_to_lteq] = ca_cache
    end
  end
end
