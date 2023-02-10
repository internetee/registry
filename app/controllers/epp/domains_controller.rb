require 'deserializers/xml/domain_delete'
module Epp
  class DomainsController < BaseController
    before_action :find_domain, only: %i[info renew update transfer delete]
    before_action :find_password, only: %i[info update transfer delete]
    before_action :set_paper_trail_whodunnit
    before_action :parse_schemas_prefix_and_version

    THROTTLED_ACTIONS = %i[info create check renew update transfer delete].freeze
    include Shunter::Integration::Throttle

    def info
      authorize! :info, @domain

      @hosts = params[:parsed_frame].css('name').first['hosts'] || 'all'

      sponsoring_registrar = (@domain.registrar == current_user.registrar)
      correct_transfer_code_provided = (@domain.transfer_code == @password)
      @reveal_full_details = (sponsoring_registrar || correct_transfer_code_provided)

      case @hosts
      when 'del'
        @nameservers = @domain.delegated_nameservers.sort
      when 'sub'
        @nameservers = @domain.subordinate_nameservers.sort
      when 'all'
        @nameservers = @domain.nameservers.sort
      end

      render_epp_response '/epp/domains/info'
    end

    def create
      authorize!(:create, Epp::Domain)

      registrar_id = current_user.registrar.id
      @domain = Epp::Domain.new
      data = ::Deserializers::Xml::DomainCreate.new(params[:parsed_frame], registrar_id).call
      action = Actions::DomainCreate.new(@domain, data)

      action.call ? render_epp_response('/epp/domains/create') : handle_errors(@domain)
    end

    def update
      authorize!(:update, @domain, @password)

      registrar_id = current_user.registrar.id
      update_params = ::Deserializers::Xml::DomainUpdate.new(params[:parsed_frame],
                                                             registrar_id).call
      action = Actions::DomainUpdate.new(@domain, update_params, false)
      unless action.call
        handle_errors(@domain)
        return
      end

      pending = @domain.epp_pending_update.present?
      render_epp_response("/epp/domains/success#{'_pending' if pending}")
    end

    def delete
      authorize!(:delete, @domain, @password)
      frame = params[:parsed_frame]
      delete_params = ::Deserializers::Xml::DomainDelete.new(frame).call
      action = Actions::DomainDelete.new(@domain, delete_params, current_user.registrar)

      (handle_errors(@domain) and return) unless action.call

      pending = @domain.epp_pending_delete.present?
      render_epp_response("/epp/domains/success#{'_pending' if pending}")
    end

    def check
      authorize! :check, Epp::Domain

      domain_names = params[:parsed_frame].css('name').map(&:text)
      @domains = Epp::Domain.check_availability(domain_names)
      render_epp_response '/epp/domains/check'
    end

    def renew
      authorize! :renew, @domain

      registrar_id = current_user.registrar.id
      renew_params = ::Deserializers::Xml::Domain.new(params[:parsed_frame],
                                                      registrar_id).call

      action = Actions::DomainRenew.new(@domain, renew_params, current_user.registrar)
      if action.call
        render_epp_response '/epp/domains/renew'
      else
        handle_errors(@domain)
      end
    end

    def transfer
      authorize! :transfer, @domain
      action = params[:parsed_frame].css('transfer').first[:op]

      if @domain.non_transferable?
        epp_errors.add(:epp_errors,
                       code: '2304',
                       msg: I18n.t(:object_status_prohibits_operation))
        handle_errors
        return
      end

      provided_transfer_code = params[:parsed_frame].css('authInfo pw').text
      wrong_transfer_code = provided_transfer_code != @domain.transfer_code

      if wrong_transfer_code
        epp_errors.add(:epp_errors,
                       code: '2202',
                       msg: 'Invalid authorization information')
        handle_errors
        return
      end

      @domain_transfer = @domain.transfer(params[:parsed_frame], action, current_user)

      if @domain.errors[:epp_errors].any?
        handle_errors(@domain)
        return
      end

      if @domain_transfer
        render_epp_response '/epp/domains/transfer'
      else
        epp_errors.add(:epp_errors,
                       code: '2303',
                       msg: I18n.t('no_transfers_found'))
        handle_errors
      end
    end

    private

    def validate_info
      @prefix = 'info > info >'
      requires('name')
      optional_attribute 'name', 'hosts', values: %(all, sub, del, none)
    end

    def validate_create
      if Domain.nameserver_required?
        @prefix = 'create > create >'
        requires 'name', 'ns', 'registrant', 'ns > hostAttr'
      end

      @prefix = 'extension > create >'
      mutually_exclusive 'keyData', 'dsData'

      @prefix = nil
      requires 'extension > extdata > legalDocument' if current_user.legaldoc_mandatory?

      optional_attribute 'period', 'unit', values: %w(d m y)

      status_editing_disabled
    end

    def validate_update
      if element_count('update > chg > registrant').positive? && current_user.legaldoc_mandatory?
        requires 'extension > extdata > legalDocument'
      end

      @prefix = 'update > update >'
      requires 'name'

      dnskey_update_enabled
      dnkey_update_prohibited
      status_editing_disabled
    end

    def parsed_response_for_dnskey(value)
      frame = params[:parsed_frame].css(value)
      return true if frame.empty?

      doc = Nokogiri::Slop frame.to_html
      return true if doc.document.children.empty?

      store = []

      case value
      when 'add'
        doc.document.add.children.each_with_index do |_x, i|
          store << doc.document.add.children[i].name
        end
      when 'chg'
        doc.document.chg.children.each_with_index do |_x, i|
          store << doc.document.chg.children[i].name
        end
      else
        doc.document.rem.children.each_with_index do |_x, i|
          store << doc.document.rem.children[i].name
        end
      end

      return true if store.size.positive? && store.include?('keyData')

      store.empty?
    end

    def dnskey_update_enabled
      find_domain

      if @domain.dnskey_update_enabled? && !params[:parsed_frame].css('update').empty?
        flag = true

        flag = false unless parsed_response_for_dnskey('chg')

        if flag
          flag = false unless parsed_response_for_dnskey('add')
        end

        if flag
          return if parsed_response_for_dnskey('rem')
        end

        epp_errors.add(:epp_errors,
                       code: '2304',
                       msg: "#{I18n.t(:object_status_prohibits_operation)} :serverObjUpdateProhibited")
      end
    end

    def dnkey_update_prohibited
      find_domain

      if @domain.extension_update_prohibited? && !params[:parsed_frame].css('keyData').empty?
        return epp_errors.add(:epp_errors,
                              code: '2304',
                              msg: "#{I18n.t(:object_status_prohibits_operation)}
                                             :serverExtensionUpdateProhibited")
      end
    end

    def validate_delete
      @prefix = 'delete > delete >'
      requires 'name'
    end

    def validate_check
      @prefix = 'check > check >'
      requires('name')
    end

    def validate_renew
      @prefix = 'renew > renew >'
      requires 'name', 'curExpDate'

      optional_attribute 'period', 'unit', values: %w(d m y)
    end

    def validate_transfer
      # period element is disabled for now
      if params[:parsed_frame].css('period').any?
        epp_errors.add(:epp_errors,
                       code: '2307',
                       msg: I18n.t(:unimplemented_object_service),
                       value: { obj: 'period' })
      end

      requires 'transfer > transfer'

      @prefix = 'transfer > transfer >'
      requires 'name'

      @prefix = nil
      requires_attribute 'transfer', 'op', values: %(approve, query, reject, request, cancel)
    end

    def find_domain
      domain_name = params[:parsed_frame].css('name').text.strip.downcase

      domain = Epp::Domain.find_by_idn(domain_name)
      raise ActiveRecord::RecordNotFound unless domain

      @domain = domain
    end

    def find_password
      @password = params[:parsed_frame].css('authInfo pw').text
    end

    def status_editing_disabled
      return true if Setting.client_status_editing_enabled
      return true if check_client_hold
      return true if params[:parsed_frame].css('status').empty?
      epp_errors.add(:epp_errors,
                     code: '2306',
                     msg: "#{I18n.t(:client_side_status_editing_error)}: status [status]")
    end

    def check_client_hold
      statuses = params[:parsed_frame].css('status').map { |element| element['s'] }
      statuses == [::DomainStatus::CLIENT_HOLD]
    end

    def balance_ok?(operation, period = nil, unit = nil)
      @domain_pricelist = @domain.pricelist(operation, period.try(:to_i), unit)
      if @domain_pricelist.try(:price) # checking if price list is not found
        if current_user.registrar.balance < @domain_pricelist.price.amount
          epp_errors.add(:epp_errors,
                         code: '2104',
                         msg: I18n.t('billing_failure_credit_balance_low'))
          return false
        end
      else
        epp_errors.add(:epp_errors,
                       code: '2104',
                       msg: I18n.t(:active_price_missing_for_this_operation))
        return false
      end
      true
    end

    def parse_schemas_prefix_and_version
      return unless params[:frame]

      xml = params[:frame].gsub!(/(?<=>)(.*?)(?=<)/, &:strip).to_s
      res = xml.match(/xmlns:domain=\"https:\/\/epp.tld.ee\/schema\/(?<prefix>\w+-\w+)-(?<version>\w.\w).xsd/)
      @schema_version = res[:version]
      @schema_prefix = res[:prefix]
    end
  end
end
