module Admin
  module Billing
    class PricesController < BaseController
      authorize_resource(class: 'Billing::Price')
      before_action :load_price, only: %i[edit update expire]
      helper_method :zones
      helper_method :operation_categories
      helper_method :durations
      helper_method :statuses

      def self.default_status
        'effective'
      end

      def index
        @search = OpenStruct.new(search_params)

        @search.status = self.class.default_status unless @search.status

        prices = ::Billing::Price.all

        prices = ::Billing::Price.send(@search.status) if @search.status.present?

        @q = prices.search(params[:q])
        if @q.sorts.empty?
          @q.sorts = ['zone_id asc', 'duration asc', 'operation_category asc',
                      'valid_from desc', 'valid_to asc']
        end
        @prices = @q.result.page(params[:page])
      end

      def new
        @price = ::Billing::Price.new
      end

      def edit; end

      def create
        @price = ::Billing::Price.new(price_params)

        if @price.save
          flash[:notice] = t('.created')
          redirect_to_index
        else
          render :new
        end
      end

      def update
        if @price.update(price_params)
          flash[:notice] = t('.updated')
          redirect_to_index
        else
          render :edit
        end
      end

      def expire
        @price.expire
        @price.save!
        flash[:notice] = t('.expired')
        redirect_to_index
      end

      private

      def load_price
        @price = ::Billing::Price.find(params[:id])
      end

      def price_params
        allowed_params = %i[
          zone_id
          operation_category
          duration
          price
          valid_from
          valid_to
        ]

        params.require(:price).permit(*allowed_params)
      end

      def search_params
        allowed_params = %i[
          status
        ]
        params.fetch(:search, {}).permit(*allowed_params)
      end

      def redirect_to_index
        redirect_to admin_prices_url
      end

      def zones
        ::DNS::Zone.all
      end

      def operation_categories
        ::Billing::Price.operation_categories
      end

      def durations
        durations = ::Billing::Price.durations
        durations.collect { |duration| [duration.sub('mon', 'month'), duration] }
      end

      def statuses
        ::Billing::Price.statuses.map { |status| [status.capitalize, status] }
      end
    end
  end
end
