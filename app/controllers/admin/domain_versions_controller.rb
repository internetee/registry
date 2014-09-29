class Admin::DomainVersionsController < AdminController
  before_action :set_domain, only: [:show]

  def index
    @q = Domain.search(params[:q])
    @domains = @q.result.page(params[:page])
  end

  def show
    @versions = @domain.versions
  end

  private
  def set_domain
    @domain = Domain.find(params[:id])
  end
end
