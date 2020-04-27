# frozen_string_literal: true

module Admin
  class DisputesController < BaseController
    load_and_authorize_resource
    before_action :set_dispute, only: %i[show edit update delete]

    # GET /admin/disputes
    def index
      params[:q] ||= {}
      disputes = Dispute.active.all.order(:domain_name)

      @q = disputes.search(params[:q])
      @disputes = @q.result.page(params[:page])
      if params[:results_per_page].to_i.positive?
        @disputes = @disputes.per(params[:results_per_page])
      end

      closed_disputes = Dispute.closed.order(:domain_name)
      @closed_q = closed_disputes.search(params[:closed_q])
      @closed_disputes = @closed_q.result.page(params[:closed_page])
      return unless params[:results_per_page].to_i.positive?

      @closed_disputes = @closed_disputes.per(params[:results_per_page])
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
        redirect_to admin_disputes_url, notice: 'Dispute was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /admin/disputes/1
    def update
      if @dispute.update(dispute_params)
        redirect_to admin_disputes_url, notice: 'Dispute was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin/disputes/1
    def delete
      @dispute.destroy
      redirect_to admin_disputes_url, notice: 'Dispute was successfully destroyed.'
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_dispute
      @dispute = Dispute.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def dispute_params
      params.require(:dispute).permit(:domain_name, :password, :starts_at, :comment)
    end
  end
end
