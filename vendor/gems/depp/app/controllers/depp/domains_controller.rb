module Depp
  class DomainsController < ApplicationController
    before_action :init_domain, except: :new

    def index
      limit, offset = pagination_details

      res = depp_current_user.repp_request('domains', { details: true, limit: limit, offset: offset })
      flash.now[:epp_results] = [{ 'code' => res.code, 'msg' => res.message }]
      @response = res.parsed_body.with_indifferent_access if res.code == '200'
      @contacts    = @response ? @response[:contacts] : []

      @paginatable_array = Kaminari.paginate_array(
        [], total_count: @response[:total_number_of_records]
      ).page(params[:page]).per(limit)
    end

    def info
      @data = @domain.info(params[:domain_name]) if params[:domain_name]
      if response_ok?
        render 'info'
      else
        flash[:alert] = t('domain_not_found')
        redirect_to domains_path and return
      end
    end

    def check
      if params[:domain_name]
        @data = @domain.check(params[:domain_name])
        render 'check_index' and return unless response_ok?
      else
        render 'check_index'
      end
    end

    def new
      @domain_params = Depp::Domain.default_params
    end

    def create
      @domain_params = params[:domain]
      @data = @domain.create(@domain_params)

      if response_ok?
        redirect_to info_domains_path(domain_name: @domain_params[:name])
      else
        render 'new'
      end
    end

    def edit
      @data = @domain.info(params[:domain_name])
      @domain_params = Depp::Domain.construct_params_from_server_data(@data)
    end

    def update
      @domain_params = params[:domain]
      @data = @domain.update(@domain_params)

      if response_ok?
        redirect_to info_domains_path(domain_name: @domain_params[:name])
      else
        params[:domain_name] = @domain_params[:name]
        render 'new'
      end
    end

    def delete; end

    def destroy
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
      if params[:domain_name] && params[:cur_exp_date]
        @data = @domain.renew(params)
        render 'renew_index' and return unless response_ok?
      else
        render 'renew_index'
      end
    end

    def transfer
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
end
