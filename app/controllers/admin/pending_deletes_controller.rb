class Admin::PendingDeletesController < AdminController
  before_action :find_domain
  before_action :check_status

  def update
    authorize! :update, :pending

    if registrant_verification.domain_registrant_delete_confirm!("admin #{current_user.username}")
      redirect_to admin_domain_path(@domain.id), notice: t(:pending_applied)
    else
      redirect_to admin_domain_path(@domain.id), alert: t(:failure)
    end
  end

  def destroy
    authorize! :destroy, :pending

    if registrant_verification.domain_registrant_delete_reject!("admin #{current_user.username}")
      redirect_to admin_domain_path(@domain.id), notice: t(:pending_removed)
    else
      redirect_to admin_domain_path(@domain.id), alert: t(:failure)
    end
  end

  private

  def registrant_verification
    # steal token
    token = @domain.registrant_verification_token
    @registrant_verification = RegistrantVerification.new(domain_id: @domain.id,
                                                          domain_name: @domain.name,
                                                          verification_token: token)
  end

  def find_domain
    @domain = Domain.find(params[:domain_id])
  end

  def check_status
    return redirect_to admin_domain_path(@domain.id), alert: t(:something_wrong) unless @domain.pending_delete?
  end
end
