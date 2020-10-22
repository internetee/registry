module Actions
  class DomainTransfer
    attr_reader :domain
    attr_reader :transfer_code
    attr_reader :legal_document
    attr_reader :ident
    attr_reader :user

    def initialize(domain, transfer_code, user)
      @domain = domain
      @transfer_code = transfer_code
      @user = user
    end

    def call
      return unless domain_exists?
      return unless run_validations

      #return domain.pending_transfer if domain.pending_transfer
      #attach_legal_document(::Deserializers::Xml::LegalDocument.new(frame).call)

      return if domain.errors[:epp_errors].any?

      commit
    end

    def domain_exists?
      return true if domain.persisted?

      domain.add_epp_error('2303', nil, nil, 'Object does not exist')

      false
    end

    def run_validations
      return unless validate_transfer_code
      return unless validate_registrar
      return unless validate_eligilibty
      return unless validate_not_discarded

      true
    end

    def validate_transfer_code
      return true if transfer_code == domain.transfer_code

      domain.add_epp_error('2202', nil, nil, 'Invalid authorization information')
      false
    end

    def validate_registrar
      return true unless user == domain.registrar

      domain.add_epp_error('2002', nil, nil, I18n.t(:domain_already_belongs_to_the_querying_registrar))
      false
    end

    def validate_eligilibty
      return true unless domain.non_transferable?

      domain.add_epp_error('2304', nil, nil, 'Domain is not transferable??')
      false
    end

    def validate_not_discarded
      return true unless domain.discarded?

      domain.add_epp_error('2106', nil, nil, 'Object is not eligible for transfer')
      false
    end

    def commit
      bare_domain = Domain.find(domain.id)
      ::DomainTransfer.request(bare_domain, user)
    end
  end
end
