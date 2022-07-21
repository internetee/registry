module Admin
  class AuctionsController < BaseController
    load_and_authorize_resource

    def index
      params[:q] ||= {}

      @auctions = Auction.with_domain_name(params[:domain_matches])
                         .with_status(params[:statuses_contains])
                         .with_start_created_at_date(params[:created_at_start])
                         .with_end_created_at_date(params[:created_at_end])
                         .order(created_at: :desc)

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
      auction = Auction.new(domain: params[:domain], status: Auction.statuses[:started], platform: 'manual')

      if Auction.domain_exists_in_blocked_disputed_and_registered?(params[:domain])
        flash[:alert] = "Adding #{params[:domain]} failed - domain registered or regsitration is blocked"
        redirect_to admin_auctions_path and return
      end

      result = check_availability(params[:domain])[0]
      if result[:avail].zero?
        flash[:alert] = "Cannot generate domain. Reason: #{result[:reason]}"
        redirect_to admin_auctions_path and return
      end

      if auction.save
        reserved_domain = auction.domain if remove_from_reserved(auction)
        flash[:notice] = "Auction #{params[:domain]} created. 
                          #{reserved_domain.present? ? 'These domain will be removed from reserved list: ' + reserved_domain : ' '}"
      else
        flash[:alert] = 'Something goes wrong'
      end

      redirect_to admin_auctions_path
    end

    def upload_spreadsheet
      if params[:q].nil?
        flash[:alert] = 'No file upload! Look at the left of upload button!'
        redirect_to admin_auctions_path and return
      end

      filename = params[:q][:file]
      table = CSV.parse(File.read(filename), headers: true)

      failed_names = []
      reserved_domains = []

      if validate_table(table)
        table.each do |row|
          record = row.to_h

          if Auction.domain_exists_in_blocked_disputed_and_registered?(record['name'])
            failed_names << record['name']

            next
          end

          result = check_availability(record['name'])[0]
          if result[:avail].zero?
            failed_names << record['name']

            next
          end

          auction = Auction.new(domain: record['name'], status: Auction.statuses[:started], platform: 'manual')
          flag = remove_from_reserved(auction) if auction.save!
          reserved_domains << auction.domain if flag
        end

        message_template = "Domains added!
                            #{reserved_domains.present? ? 
                              'These domains will be removed from reserved list: ' + reserved_domains.join(' ') + '! ' 
                              : '! '}
                            #{failed_names.present? ? 'These domains were ignored: ' + failed_names.join(' ') : '!'}"

        flash[:notice] = message_template
      else
        flash[:alert] = "Invalid CSV format. Should be column with 'name' where is the list of name of domains!"
      end

      redirect_to admin_auctions_path
    end

    private

    def check_availability(domain_name)
      Epp::Domain.check_availability(domain_name)
    end

    def validate_table(table)
      first_row = table.headers
      first_row.include? 'name'
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
