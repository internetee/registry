class Admin::ReservedDomainsController < AdminController
  load_and_authorize_resource

  def index
    names = ReservedDomain.pluck(:name, :password).each_with_object({}){|domain, hash| hash[domain[0]] = domain[1]}
    names.names = nil if names.blank?
    @reserved_domains = names.to_yaml.gsub(/---.?\n/, '').gsub(/\.\.\..?\n/, '')
  end

  def create
    @reserved_domains = params[:reserved_domains]

    begin
      params[:reserved_domains] = "---\n" if params[:reserved_domains].blank?
      names = YAML.load(params[:reserved_domains])
      fail if names == false
    rescue
      flash.now[:alert] = I18n.t('invalid_yaml')
      logger.warn 'Invalid YAML'
      render :index and return
    end

    result = true
    ReservedDomain.transaction do
      # removing old ones
      existing = ReservedDomain.any_of_domains(names.keys).pluck(:id)
      ReservedDomain.where.not(id: existing).destroy_all

      #updating and adding
      names.each do |name, psw|
        rec = ReservedDomain.find_or_initialize_by(name: name)
        rec.password = psw

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
