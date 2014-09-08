class Admin::DomainsController < ApplicationController
  before_action :set_domain, only: [:show]

  def new
    @domain = Domain.new
  end

  def index
    @q = Domain.search(params[:q])
    @domains = @q.result.page(params[:page])
  end

  private

  def set_domain
    @domain = Domain.find(params[:id])
  end
end
