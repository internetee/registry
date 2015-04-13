class Registrar::DomainsController < Registrar::DeppController # EPP controller 
  before_action :init_domain, except: :new

  def index
    authorize! :view, Depp::Domain
    limit, offset = pagination_details

    res = depp_current_user.repp_request('domains', { details: true, limit: limit, offset: offset })
    if res.code == '200'
      @response = res.parsed_body.with_indifferent_access 
      @contacts = @response ? @response[:contacts] : []

      @paginatable_array = Kaminari.paginate_array(
        [], total_count: @response[:total_number_of_records]
      ).page(params[:page]).per(limit)
    end
    flash.now[:epp_results] = [{ 'code' => res.code, 'msg' => res.message }]
  end

  def info
    authorize! :view, Depp::Domain
    @data = @domain.info(params[:domain_name]) if params[:domain_name]
    if response_ok?
      render 'info'
    else
      flash[:alert] = t('domain_not_found')
      redirect_to domains_path and return
    end
  end

  def check
    authorize! :view, Depp::Domain
    if params[:domain_name]
      @data = @domain.check(params[:domain_name])
      render 'check_index' and return unless response_ok?
    else
      render 'check_index'
    end
  end

  def new
    authorize! :create, Depp::Domain
    @domain_params = Depp::Domain.default_params
  end

  def create
    authorize! :create, Depp::Domain
    @domain_params = params[:domain]
    @data = @domain.create(@domain_params)

    if response_ok?
      redirect_to info_domains_path(domain_name: @domain_params[:name])
    else
      render 'new'
    end
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
      redirect_to info_domains_path(domain_name: @domain_params[:name])
    else
      params[:domain_name] = @domain_params[:name]
      render 'new'
    end
  end

  def delete
    authorize! :delete, Depp::Domain
  end

  def destroy
    authorize! :delete, Depp::Domain
    @data = @domain.delete(params[:domain])
    @results = @data.css('result')
    if response_ok?
      params[:domain_name] = nil
      render 'info_index'
    else
      params[:domain_name] = params[:domain][:name]
      render 'delete'
    end
  end

  def renew
    authorize! :renew, Depp::Domain
    if params[:domain_name] && params[:cur_exp_date]
      @data = @domain.renew(params)
      render 'renew_index' and return unless response_ok?
    else
      render 'renew_index'
    end
  end

  def transfer
    authorize! :transfer, Depp::Domain
    if params[:domain_name]
      @data = @domain.transfer(params)
      render 'transfer_index' and return unless response_ok?
    else
      render 'transfer_index'
    end
  end

  private

  def init_domain
    @domain = Depp::Domain.new(current_user: depp_current_user)
  end
end
