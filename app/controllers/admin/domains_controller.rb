class Admin::DomainsController < ApplicationController
  def index
    @domains = Domain.order(:name).page(params[:page])
  end
end
