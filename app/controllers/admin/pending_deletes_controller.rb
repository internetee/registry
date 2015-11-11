class Admin::PendingDeletesController < AdminController
  before_action :find_domain
  before_action :check_status

  def update
    authorize! :update, :pending

    @epp_domain = Epp::Domain.find(params[:domain_id]) # only epp domain has apply pending
    @epp_domain.is_admin= true
    if @epp_domain.apply_pending_delete!
      redirect_to admin_domain_path(@domain.id), notice: t(:pending_applied)
    else
      redirect_to admin_edit_domain_path(@domain.id), alert: t(:failure)
    end
  end

  def destroy
    authorize! :destroy, :pending

    @epp_domain.is_admin= true
    if @domain.clean_pendings!
      redirect_to admin_domain_path(@domain.id), notice: t(:pending_removed)
    else
      redirect_to admin_domain_path(@domain.id), alert: t(:failure)
    end
  end

  private

  def find_domain
    @domain = Domain.find(params[:domain_id])
  end

  def check_status
    return redirect_to admin_domain_path(@domain.id), alert: t(:something_wrong) unless @domain.pending_delete?
  end
end
