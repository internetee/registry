class Admin::PricelistsController < AdminController
  load_and_authorize_resource
  before_action :set_pricelist, only: [:show, :edit, :update]

  def index
    @q = Pricelist.search(params[:q])
    @q.sorts = ['category asc', 'duration asc', 'operation_category asc', 'valid_from desc', 'valid_to asc'] if @q.sorts.empty?
    @pricelists = @q.result.page(params[:page])
  end

  def new
    @pricelist = Pricelist.new
  end

  def edit
  end

  def create
    @pricelist = Pricelist.new(pricelist_params)

    if @pricelist.save
      redirect_to admin_pricelists_url
    else
      render 'new'
    end
  end

  def update
    if @pricelist.update_attributes(pricelist_params)
      redirect_to admin_pricelists_url
    else
      render 'edit'
    end
  end

  def destroy
    @pricelist.destroy
    redirect_to admin_pricelists_url
  end

  private

  def set_pricelist
    @pricelist = Pricelist.find(params[:id])
  end

  def pricelist_params
    params.require(:pricelist).permit(:operation_category, :category, :price_category,
                                      :duration, :price, :valid_from, :valid_to)
  end
end
