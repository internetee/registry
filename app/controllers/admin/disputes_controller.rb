# frozen_string_literal: true

module Admin
  class DisputesController < BaseController
    load_and_authorize_resource
    before_action :set_dispute, only: %i[show edit update destroy]

    # GET /admin/disputes
    def index
      params[:q] ||= {}
      disputes = Dispute.all.order(:domain_name)
      @q = disputes.search(params[:q])
      @disputes = @q.result.page(params[:page])
      @disputes = @disputes.per(params[:results_per_page]) if params[:results_per_page].to_i.positive?
    end

    # GET /admin/disputes/1
    def show; end

    # GET /admin/disputes/new
    def new
      @dispute = Dispute.new
    end

    # GET /admin/disputes/1/edit
    def edit; end

    # POST /admin/disputes
    def create
      @dispute = Dispute.new(dispute_params)

      if @dispute.save
        redirect_to @dispute, notice: 'Dispute was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /admin/disputes/1
    def update
      if @dispute.update(dispute_params)
        redirect_to @dispute, notice: 'Dispute was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin/disputes/1
    def destroy
      @dispute.destroy
      redirect_to disputes_url, notice: 'Dispute was successfully destroyed.'
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_dispute
      @dispute = Dispute.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def dispute_params
      params.require(:dispute).permit(:domain_name, :password, :expires_at, :comment, :created_at)
    end
  end
end
