module Admin
  class AuctionsController < BaseController
    load_and_authorize_resource

    def index
      params[:q] ||= {}

      @auctions = Auction.with_status(params[:statuses_contains])
      @auction = Auction.new

      normalize_search_parameters do
        @q = @auctions.ransack(PartialSearchFormatter.format(params[:q]))
        @auctions = @q.result.page(params[:page])
      end

      @auctions = @auctions.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      domains = ReservedDomain.all.order(:name)
      q = domains.ransack(PartialSearchFormatter.format(params[:q]))
      @domains = q.result.page(params[:page])
      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/auctions/index', 'auctions')
    end

    def create
      auction = Auction.new(domain: params[:domain], status: Auction.statuses[:started], platform: :english)

      if auction.save
        remove_from_reserved(auction)
        flash[:notice] = "Auction #{params[:domain]} created"
      else
        flash[:alert] = "Something goes wrong"
      end

      redirect_to admin_auctions_path
    end

    def upload_spreadsheet
      table = CSV.parse(File.read(params[:q][:file]), headers: true)

      table.each do |row|
        record = row.to_h
        auction = Auction.new(domain: record['name'], status: Auction.statuses[:started], platform: :english)
        remove_from_reserved(auction) if auction.save!
      end

      redirect_to admin_auctions_path
    end

    private

    def remove_from_reserved(auction)
      domain = ReservedDomain.find_by(name: auction.domain)

      domain.destroy if domain.present?
    end

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
