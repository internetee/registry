class Admin::DomainVersionsController < AdminController
  load_and_authorize_resource

  def index
    @domain = Domain.where(id: params[:domain_id]).includes({versions: :item}).first
    @versions = @domain.versions
  end
end
