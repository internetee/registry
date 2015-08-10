class Admin::DomainVersionsController < AdminController
  load_and_authorize_resource

  def index
    @domain = Domain.find(params[:domain_id])
    @versions = @domain.versions

    if @domain.pending_json.present?
      frame = Nokogiri::XML(@domain.pending_json['frame'])
      @pending_user  = User.find(@domain.pending_json['current_user_id'])
      @pending_domain = Epp::Domain.new_from_epp(frame, @pending_user)
    end
  end

  # def index
    # # @q = DomainVersion.deleted.search(params[:q])
    # # @domains = @q.result.page(params[:page])
  # end

  # def show
    # @versions = DomainVersion.where(item_id: params[:id])
  # end
end
