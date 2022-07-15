module Actions
  class DomainDelete
    attr_reader :domain, :params, :user

    def initialize(domain, params, user)
      @domain = domain
      @params = params
      @user = user
    end

    def call
      return false unless @domain.can_be_deleted?

      verify_not_discarded
      maybe_attach_legal_doc

      return false if domain.errors.any?
      return false if domain.errors[:epp_errors].any?

      destroy
    end

    def maybe_attach_legal_doc
      ::Actions::BaseAction.attach_legal_doc_to_new(domain, params[:legal_document], domain: true)
    end

    def verify_not_discarded
      return unless domain.discarded?

      domain.add_epp_error('2304', nil, nil, 'Object status prohibits operation')
    end

    def verify?
      return false unless Setting.request_confirmation_on_domain_deletion_enabled
      return false if true?(params[:delete][:verified])

      true
    end

    def ask_delete_verification
      domain.registrant_verification_asked!(params, user.id)
      domain.pending_delete!
      domain.manage_automatic_statuses
    end

    def destroy
      if verify?
        ask_delete_verification
      else
        domain.set_pending_delete!
      end
      true
    end

    def true?(obj)
      obj.to_s.downcase == 'true'
    end
  end
end
