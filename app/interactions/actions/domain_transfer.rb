module Actions
  class DomainTransfer
    attr_reader :domain, :transfer_code, :legal_document, :ident, :user

    def initialize(domain, transfer_code, user)
      @domain = domain
      @transfer_code = transfer_code
      @user = user
    end

    def call
      return false unless domain_exists?
      return false unless valid_transfer_code?

      run_validations

      # return domain.pending_transfer if domain.pending_transfer
      # attach_legal_document(::Deserializers::Xml::LegalDocument.new(frame).call)

      return false if domain.errors[:epp_errors].any?

      commit
      true
    end

    def domain_exists?
      return true if domain.persisted?

      domain.add_epp_error('2303', nil, nil, 'Object does not exist')

      false
    end

    def run_validations
      validate_registrar
      validate_eligilibty
      validate_not_discarded
      validate_ns_records
      validate_dns_records
    end

    def valid_transfer_code?
      return true if transfer_code == domain.transfer_code

      domain.add_epp_error('2202', nil, nil, 'Invalid authorization information')
      false
    end

    def validate_registrar
      return unless user == domain.registrar

      domain.add_epp_error('2002', nil, nil,
                           I18n.t(:domain_already_belongs_to_the_querying_registrar))
    end

    def validate_eligilibty
      return unless domain.non_transferable?

      domain.add_epp_error('2304', nil, nil, 'Object status prohibits operation')
    end

    def validate_not_discarded
      return unless domain.discarded?

      domain.add_epp_error('2106', nil, nil, 'Object is not eligible for transfer')
    end

    def validate_ns_records
      return unless domain.nameservers.any?

      result = DNSValidator.validate(domain: domain, name: domain.name, record_type: 'NS')
      return if result[:errors].blank?

      assign_dns_validation_error(result[:errors])
    end

    def validate_dns_records
      return unless domain.dnskeys.any?

      result = DNSValidator.validate(domain: domain, name: domain.name, record_type: 'DNSKEY')
      return if result[:errors].blank?

      assign_dns_validation_error(result[:errors])
    end

    def assign_dns_validation_error(errors)
      errors.each do |error|
        domain.add_epp_error('2306', nil, nil, error)
      end
    end

    def commit
      bare_domain = Domain.find(domain.id)
      ::DomainTransfer.request(bare_domain, user)
    end
  end
end
