module Admin
  class AuctionsController < BaseController
    load_and_authorize_resource

    def index
      params[:q] ||= {}

      @auctions = Auction.with_domain_name(params[:domain_matches])
                         .with_status(params[:statuses_contains])
                         .with_start_created_at_date(params[:created_at_start])
                         .with_end_created_at_date(params[:created_at_end])

      @auction = Auction.new

      normalize_search_parameters do
        @q = @auctions.ransack(PartialSearchFormatter.format(params[:q]))
        @auctions = @q.result.page(params[:page])
      end

      @auctions = @auctions.per(params[:results_per_page_auction]) if params[:results_per_page_auction].to_i.positive?

      domains = ReservedDomain.all.order(:name)
      q = domains.ransack(PartialSearchFormatter.format(params[:q]))
      @domains = q.result.page(params[:page])
      @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?

      render_by_format('admin/auctions/index', 'auctions')
    end

    def create
      auction = Auction.new(domain: params[:domain], status: Auction.statuses[:started], platform: 'manually')

      if auction.save
        remove_from_reserved(auction)
        flash[:notice] = "Auction #{params[:domain]} created"
      else
        flash[:alert] = 'Something goes wrong'
      end

      redirect_to admin_auctions_path
    end

    def upload_spreadsheet
      filename = params[:q][:file]
      table = CSV.parse(File.read(filename), headers: true)

      if validate_table(table)
        table.each do |row|
          record = row.to_h
          auction = Auction.new(domain: record['name'], status: Auction.statuses[:started], platform: 'manually')
          remove_from_reserved(auction) if auction.save!
        end
        flash[:notice] = "Domains added"
        redirect_to admin_auctions_path
      else
        flash[:alert] = "Invalid CSV format."
        redirect_to admin_auctions_path
      end
    end

    private

    def validate_table(table)
      first_row = table.headers
      first_row[0] == 'id' &&
        first_row[1] == 'created_at' &&
        first_row[2] == 'updated_at' &&
        first_row[3] == 'creator_str' &&
        first_row[4] == 'updator_str' &&
        first_row[5] == 'name'
    end

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
