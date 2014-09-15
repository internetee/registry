class Admin::DomainsController < ApplicationController
  before_action :set_domain, only: [:show, :edit, :update]

  def new
    @domain = Domain.new
  end

  def create
    @domain = Domain.new(domain_params)

    if @domain.save
      redirect_to [:admin, @domain]
    else
      render 'new'
    end
  end

  def index
    @q = Domain.search(params[:q])
    @domains = @q.result.page(params[:page])
  end

  def show
    @domain.all_dependencies_valid?
  end

  def edit
    params[:registrar] = @domain.registrar
    params[:owner_contact] = @domain.owner_contact_code
  end

  def update
    if @domain.update(domain_params)
      redirect_to [:admin, @domain]
    else
      render 'edit'
    end
  end

  private

  def set_domain
    @domain = Domain.find(params[:id])
  end

  def domain_params
    params.require(:domain).permit(:name, :period, :period_unit, :registrar_id, :owner_contact_id)
  end
end

