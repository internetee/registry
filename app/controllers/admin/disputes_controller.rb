# frozen_string_literal: true

module Admin
  class DisputesController < BaseController
    load_and_authorize_resource
    before_action :set_dispute, only: %i[show edit update delete]

    # GET /admin/disputes
    def index
      params[:q] ||= {}
      @disputes = sortable_dispute_query_for(Dispute.active.all, params[:q])
      @closed_disputes = sortable_dispute_query_for(Dispute.closed.all, params[:q], closed: true)
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
        notice = 'Dispute was successfully created'
        notice += @dispute.domain ? '.' : ' for domain that is not registered.'

        redirect_to admin_disputes_url, notice: notice
      else
        render :new
      end
    end

    # PATCH/PUT /admin/disputes/1
    def update
      if @dispute.update(dispute_params.except(:domain_name))
        redirect_to admin_disputes_url, notice: 'Dispute was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin/disputes/1
    def delete
      @dispute.close(initiator: 'Admin')
      redirect_to admin_disputes_url, notice: 'Dispute was successfully closed.'
    end

    private

    def sortable_dispute_query_for(disputes, query, closed: false)
      @q = disputes.order(:domain_name).search(query)
      disputes = @q.result.page(closed ? params[:closed_page] : params[:page])
      return disputes.per(params[:results_per_page]) if params[:results_per_page].present?

      disputes
    end

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
