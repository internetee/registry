class Admin::BlockedDomainsController < AdminController
  load_and_authorize_resource

  def index
    bd = BlockedDomain.pluck(:name)
    if bd
      @blocked_domains = bd.to_yaml.gsub("---\n", '').gsub("-", '').gsub(" ", '')
    end
  end

  def create
    @blocked_domains = params[:blocked_domains]

    begin
      params[:blocked_domains] = "---\n" if params[:blocked_domains].blank?
      names = YAML.load(params[:blocked_domains])
      fail if names == false
    rescue
      flash.now[:alert] = I18n.t('invalid_yaml')
      logger.warn 'Invalid YAML'
      render :index and return
    end

    names = names.split(' ')
    result = true
    BlockedDomain.transaction do
      existing = BlockedDomain.any_of_domains(names).pluck(:id)
      BlockedDomain.where.not(id: existing).destroy_all

      names.each do |name|
        rec = BlockedDomain.find_or_initialize_by(name: name)
        unless rec.save
          result = false
          raise ActiveRecord::Rollback
        end
      end
    end

    if result
      flash[:notice] = I18n.t('record_updated')
      redirect_to :back
    else
      flash.now[:alert] = I18n.t('failed_to_update_record')
      render :index
    end
  end
end
