class Admin::ReservedDomainsController < AdminController
  load_and_authorize_resource

  def index
    rd = ReservedDomain.first_or_initialize
    @reserved_domains = rd.names.to_yaml.gsub("---\n", '')
  end

  def create
    @reserved_domains = params[:reserved_domains]

    begin
      names = YAML.load(params[:reserved_domains])
      fail if names == false
    rescue
      flash.now[:alert] = I18n.t('invalid_yaml')
      logger.warn 'Invalid YAML'
      render :index and return
    end

    rd = ReservedDomain.first_or_create

    if rd.update(names: names)
      flash[:notice] = I18n.t('record_updated')
      redirect_to :back
    else
      flash.now[:alert] = I18n.t('failed_to_update_record')
      render :index
    end
  end
end
