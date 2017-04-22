module Admin
  module DNS
    class ZonesController < AdminController
      load_and_authorize_resource(class: DNS::Zone)
      before_action :load_zone, only: %i[edit update destroy]

      def index
        @zones = ::DNS::Zone.all
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

      def destroy
        @zone.destroy!
        flash[:notice] = t('.destroyed')
        redirect_to_index
      end

      private

      def load_zone
        @zone = ::DNS::Zone.find(params[:id])
      end

      def zone_params
        params.require(:zone).permit(
          :origin, :ttl, :refresh, :retry, :expire, :minimum_ttl, :email,
          :master_nameserver, :ns_records, :a_records, :a4_records
        )
      end

      def redirect_to_index
        redirect_to admin_zones_url
      end
    end
  end
end
