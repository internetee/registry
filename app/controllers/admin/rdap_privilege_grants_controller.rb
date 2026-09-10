module Admin
  class RdapPrivilegeGrantsController < BaseController
    load_and_authorize_resource

    def index
      @q = RdapPrivilegeGrant.ransack(params[:q])
      @rdap_privilege_grants = @q.result.page(params[:page]).order(created_at: :desc)
      @count = @q.result.count
      @rdap_privilege_grants = @rdap_privilege_grants.per(params[:results_per_page]) if paginate?
    end

    def new
      @rdap_privilege_grant = RdapPrivilegeGrant.new
    end

    def show; end

    def edit; end

    def create
      @rdap_privilege_grant = RdapPrivilegeGrant.new(rdap_privilege_grant_params)

      if @rdap_privilege_grant.save
        flash[:notice] = I18n.t('record_created')
        redirect_to [:admin, @rdap_privilege_grant]
      else
        flash.now[:alert] = I18n.t('failed_to_create_record')
        render 'new'
      end
    end

    def update
      if @rdap_privilege_grant.update(rdap_privilege_grant_params)
        flash[:notice] = I18n.t('record_updated')
        redirect_to [:admin, @rdap_privilege_grant]
      else
        flash.now[:alert] = I18n.t('failed_to_update_record')
        render 'edit'
      end
    end

    # Suspend and revoke are distinct member actions that change only `status`,
    # never a generic edit of unrelated fields (RPD §9 lines 461; AC4/AC5).
    def suspend
      @rdap_privilege_grant.update!(status: 'suspended')
      flash[:notice] = I18n.t('admin.rdap_privilege_grants.grant_suspended')
      redirect_to [:admin, @rdap_privilege_grant]
    end

    def revoke
      @rdap_privilege_grant.update!(status: 'revoked')
      flash[:notice] = I18n.t('admin.rdap_privilege_grants.grant_revoked')
      redirect_to [:admin, @rdap_privilege_grant]
    end

    private

    def rdap_privilege_grant_params
      params.require(:rdap_privilege_grant).permit(:eeid_subject,
                                                   :full_name,
                                                   :legal_basis_ref,
                                                   :personal_id_code,
                                                   :organization,
                                                   :category,
                                                   :valid_from,
                                                   :valid_until,
                                                   :notes)
    end
  end
end
