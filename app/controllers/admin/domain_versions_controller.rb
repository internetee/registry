class Admin::DomainVersionsController < AdminController
  load_and_authorize_resource

  # rubocop:disable Style/GuardClause
  def index
  # @domain = Domain.where(id: params[:domain_id]).includes({versions: :item}).first
  # @versions = @domain.versions

    # Depricated it had to load legal document. We may do it by parsing and adding link.
    # if @domain.pending_json.present?
    #   frame = Nokogiri::XML(@domain.pending_json['frame'])
    #   @pending_user  = User.find(@domain.pending_json['current_user_id'])
    #   @pending_domain = Epp::Domain.find(@domain.id)
    #   @pending_domain.update(frame, @pending_user, false)
    # end
  end
  # rubocop:enable Style/GuardClause
  end
