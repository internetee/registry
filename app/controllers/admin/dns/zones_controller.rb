module Admin
  module DNS
    class ZonesController < BaseController
      authorize_resource(class: 'DNS::Zone')
      before_action :load_zone, only: %i[edit update destroy]

      def index
        @q = ::DNS::Zone.ransack(params[:q])
        @count = @q.result.count
        @zones = @q.result.page(params[:page]).per(params[:results_per_page])
      end

      def new
        @zone = ::DNS::Zone.new
      end

      def create
        @zone = ::DNS::Zone.new(zone_params)

        if @zone.save
          flash[:notice] = t('.created')
          redirect_to_index
        else
          render :new
        end
      end

      def edit
        @zone = ::DNS::Zone.find(params[:id])
      end

      def update
        if @zone.update(zone_params)
          flash[:notice] = t('.updated')
          redirect_to_index
        else
          render :edit
        end
      end

      private

      def load_zone
        @zone = ::DNS::Zone.find(params[:id])
      end

      def zone_params
        allowed_params = %i[
          origin
          ttl
          refresh
          retry
          expire
          minimum_ttl
          email
          master_nameserver
          ns_records
          a_records
          a4_records
        ]

        params.require(:zone).permit(*allowed_params)
      end

      def redirect_to_index
        redirect_to admin_zones_url
      end
    end
  end
end
