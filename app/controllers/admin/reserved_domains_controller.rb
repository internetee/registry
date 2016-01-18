class Admin::ReservedDomainsController < AdminController
  load_and_authorize_resource

  def index

    params[:q] ||= {}
    domains = ReservedDomain.all
    @q = domains.search(params[:q])
    @domains = @q.result.page(params[:page])
    @domains = @domains.per(params[:results_per_page]) if params[:results_per_page].to_i > 0

  end

  def new
    @domain = ReservedDomain.new
  end

  def edit
    authorize! :update, Depp::Domain
    @data = @domain.info(params[:domain_name])
    @domain_params = Depp::Domain.construct_params_from_server_data(@data)
  end

  def update
    authorize! :update, Depp::Domain
    @domain_params = params[:domain]
    @data = @domain.update(@domain_params)

    if response_ok?
      redirect_to info_registrar_domains_url(domain_name: @domain_params[:name])
    else
      params[:domain_name] = @domain_params[:name]
      render 'new'
    end
  end

  def delete
    authorize! :delete, Depp::Domain
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
