class Registrant::DomainDeleteConfirmsController < RegistrantController
  skip_before_action :authenticate_registrant_user!, only: [:show, :update]
  skip_authorization_check only: [:show, :update]

  def show
    return if params[:confirmed] || params[:rejected]

    @domain = Domain.find(params[:id])
    @domain = nil unless @domain.registrant_delete_confirmable?(params[:token])
  end

  def update
    @domain = Domain.find(params[:id])
    unless @domain.registrant_delete_confirmable?(params[:token])
      flash[:alert] = t(:registrant_domain_verification_failed)
      return render 'show'
    end

    @registrant_verification = RegistrantVerification.new(domain_id: @domain.id,
                                                          verification_token: params[:token])

    initiator = current_registrant_user ? current_registrant_user.username :
                  t(:user_not_authenticated)

    confirmed = params[:confirmed] ? true : false
    action = if confirmed
               @registrant_verification.domain_registrant_delete_reject!("email link #{initiator}")
             else
               @registrant_verification.domain_registrant_delete_confirm!("email link #{initiator}")
             end

    fail_msg = t("registrant_domain_delete_#{confirmed ? 'confirmed' : 'rejected'}_failed".to_sym)
    success_msg = t("registrant_domain_verification_#{confirmed ? 'confirmed' : 'rejected'}".to_sym)

    flash[:alert] = action ? success_msg : fail_msg
    (render 'show' && return) unless action

    if confirmed
      redirect_to registrant_domain_delete_confirm_path(@domain.id, confirmed: true) && return
    else
      redirect_to registrant_domain_delete_confirm_path(@domain.id, rejected: true) unless confirmed
    end
  end
end
