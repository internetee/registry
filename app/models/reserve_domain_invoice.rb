# frozen_string_literal: true

class ReserveDomainInvoice < ApplicationRecord
  class InvoiceStruct < Struct.new(:total, :number, :buyer_name, :buyer_email,
    :description, :initiator, :reference_no, :reserved_domain_names,
    keyword_init: true)
  end

  class InvoiceResponseStruct < Struct.new(:status_code_success, :linkpay, :invoice_number, :details, 
    keyword_init: true)
  end

  INITIATOR = 'business_registry'
  HTTP_OK = '200'
  HTTP_CREATED = '201'
  DEFAULT_AMOUNT = '10.00'

  class << self
    def create_list_of_domains(domain_names)
      normalized_names = normalize_domain_names(domain_names)
      available_names = filter_available_domains(normalized_names)

      return if available_names.empty?

      invoice = create_invoice_with_domains(available_names)
      result = process_invoice(invoice)
      
      create_reserve_domain_invoice(invoice.number, available_names)
      build_response(result, invoice.number)
    end

    def is_any_available_domains?(domain_names)
      normalized_names = normalize_domain_names(domain_names)
      filter_available_domains(normalized_names).any?
    end

    def filter_available_domains(names)
      BusinessRegistry::DomainAvailabilityCheckerService.filter_available(names)
    end

    private

    def normalize_domain_names(names)
      names.map { |name| normalize_name(name) }
    end

    def normalize_name(name)
      SimpleIDN.to_unicode(name).mb_chars.downcase.strip.to_s
    end

    def create_invoice_with_domains(domain_names)
      invoice_number = fetch_invoice_number
      
      build_invoice(
        total: DEFAULT_AMOUNT,
        number: invoice_number,
        reserved_domain_names: domain_names
      )
    end

    def fetch_invoice_number
      response = EisBilling::GetInvoiceNumber.call
      JSON.parse(response.body).fetch('invoice_number').to_i
    end

    def build_invoice(attributes)
      InvoiceStruct.new(
        total: attributes[:total],
        number: attributes[:number],
        buyer_name: nil,
        buyer_email: nil,
        description: 'description',
        initiator: INITIATOR,
        reference_no: nil,
        reserved_domain_names: attributes[:reserved_domain_names]
      )
    end

    def process_invoice(invoice)
      EisBilling::AddDeposits.new(invoice).call
    end

    def create_reserve_domain_invoice(invoice_number, domain_names)
      create(
        invoice_number: invoice_number,
        domain_names: domain_names
      )
    end

    def build_response(result, invoice_number)
      parsed_result = JSON.parse(result.body)
      
      InvoiceResponseStruct.new(
        status_code_success: success_status?(result.code),
        linkpay: parsed_result['everypay_link'],
        invoice_number: invoice_number,
        details: parsed_result
      )
    end

    def success_status?(status_code)
      status_code == HTTP_OK || status_code == HTTP_CREATED
    end
  end

  def invoice_state
    EisBilling::GetReservedDomainsInvoiceStatus.call(invoice_number: invoice_number)
  end

  def create_reserved_domains
    domain_names.map { |name| ReservedDomain.create(name: name) if ReservedDomain.find_by(name: name).nil? }
  end

  def build_reserved_domains_output
    domain_names.map { |name| ReservedDomain.where(name: name).pluck(:name, :password).to_h }
  end
end
