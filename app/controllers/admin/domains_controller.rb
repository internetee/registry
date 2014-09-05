class Admin::DomainsController < ApplicationController
  def index
    @q = Domain.search(params[:q])
    @domains = @q.result.page(params[:page])
  end
end
