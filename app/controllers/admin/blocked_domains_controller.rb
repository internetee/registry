class Admin::BlockedDomainsController < AdminController
  load_and_authorize_resource

  def index
    bd = BlockedDomain.first_or_initialize
    @blocked_domains = bd.names.join("\n")
  end

  def create
    names = params[:blocked_domains].split("\r\n").map(&:strip)

    bd = BlockedDomain.first_or_create

    if bd.update(names: names)
      flash[:notice] = I18n.t('record_updated')
      redirect_to :back
    else
      @blocked_domains = params[:blocked_domains]
      flash.now[:alert] = I18n.t('failed_to_update_record')
      render :index
    end

  end
end
