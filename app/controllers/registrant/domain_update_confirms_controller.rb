class Registrant::DomainUpdateConfirmsController < RegistrantController
  skip_before_action :authenticate_registrant_user!, only: %i[show update]
  skip_authorization_check only: %i[show update]

  def show
    return if params[:confirmed] || params[:rejected]
    @domain = Domain.find(params[:id])
    @domain = nil unless @domain.registrant_update_confirmable?(params[:token])
  end

  def update
    @domain = Domain.find(params[:id])
    unless @domain.registrant_update_confirmable?(params[:token])
      flash[:alert] = t(:registrant_domain_verification_failed)
      return render 'show'
    end

    @registrant_verification = RegistrantVerification.new(domain_id: @domain.id,
                                                          verification_token: params[:token])

    initiator = current_registrant_user ? current_registrant_user.username :
                  t(:user_not_authenticated)

    if params[:rejected]
      if @registrant_verification.domain_registrant_change_reject!("email link, #{initiator}")
        flash[:notice] = t(:registrant_domain_verification_rejected)
        redirect_to registrant_domain_update_confirm_path(@domain.id, rejected: true)
      else
        flash[:alert] = t(:registrant_domain_verification_rejected_failed)
        return render 'show'
      end
    elsif params[:confirmed]
      if @registrant_verification.domain_registrant_change_confirm!("email link, #{initiator}")
        flash[:notice] = t(:registrant_domain_verification_confirmed)
        redirect_to registrant_domain_update_confirm_path(@domain.id, confirmed: true)
      else
        flash[:alert] = t(:registrant_domain_verification_confirmed_failed)
        return render 'show'
      end
    end
  end
end
