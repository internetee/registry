class Admin::DomainVersionsController < AdminController
  load_and_authorize_resource

  # rubocop:disable Style/GuardClause
  def index
    @domain = Domain.where(id: params[:domain_id]).includes({versions: :item}).first
    @versions = @domain.versions

    if @domain.pending_json.present?
      frame = Nokogiri::XML(@domain.pending_json['frame'])
      @pending_user  = User.find(@domain.pending_json['current_user_id'])
      @pending_domain = Epp::Domain.new_from_epp(frame, @pending_user)
    end
  end
  # rubocop:enable Style/GuardClause
end
