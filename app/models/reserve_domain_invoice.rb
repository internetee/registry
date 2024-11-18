# frozen_string_literal: true

class ReserveDomainInvoice < ApplicationRecord
  class InvoiceStruct < Struct.new(:total, :number, :buyer_name, :buyer_email,
    :description, :initiator, :reference_no, :reserved_domain_names, :user_unique_id,
    keyword_init: true)
  end

  class InvoiceResponseStruct < Struct.new(:status_code_success, :oneoff_payment_link, :invoice_number, :details, :user_unique_id,
    keyword_init: true)
  end

  INITIATOR = 'business_registry'
  HTTP_OK = '200'
  HTTP_CREATED = '201'
  ONE_OFF_CUSTOMER_URL = 'https://registry.test/eis_billing/callback'
  DEFAULT_AMOUNT = 10.00 # this need to move to the admin panel


  enum status: { pending: 0, paid: 1, cancelled: 2, failed: 3 }

  class << self
    def create_list_of_domains(domain_names)
      # TODO: need to refactor this
      normalized_names = normalize_domain_names(domain_names)
      available_names = filter_available_domains(normalized_names)

      return build_error_response('No available domains') if available_names.empty?
      check_state_of_intersecting_invoices(available_names) if are_domains_intersect?(available_names)

      return build_error_response('Some intersecting invoices are paid') if is_any_intersecting_invoice_paid?(available_names)

      user_unique_id = generate_unique_id      

      invoice = if are_domains_intersect?(available_names)
        invoice_number = get_invoice_number_from_intersecting_invoice(available_names).to_i
        create_invoice_with_domains(available_names, invoice_number: invoice_number, user_unique_id: user_unique_id)
      else
        create_invoice_with_domains(available_names, user_unique_id: user_unique_id)
      end

      result = process_invoice(invoice)
      create_reserve_domain_invoice(invoice.number, available_names, invoice.user_unique_id)
      build_response(result, invoice.number, invoice.user_unique_id)
    end

    def are_domains_intersect?(domain_names)
      pending_invoices = ReserveDomainInvoice.pending.where('domain_names && ARRAY[?]::varchar[]', domain_names)
      pending_invoices.any?
    end

    def get_invoice_number_from_intersecting_invoice(domain_names)
      pending_invoices = ReserveDomainInvoice.pending.where('domain_names && ARRAY[?]::varchar[]', domain_names)
      pending_invoices.first.invoice_number
    end

    def is_any_intersecting_invoice_paid?(domain_names)
      intersecting_invoices = ReserveDomainInvoice.paid.where('domain_names && ARRAY[?]::varchar[]', domain_names)
      intersecting_invoices.any?
    end

    def cancel_intersecting_invoices(domain_names)
      intersecting_invoices = ReserveDomainInvoice.pending.where('domain_names && ARRAY[?]::varchar[]', domain_names)
      intersecting_invoices.update_all(status: :cancelled)
    end

    def check_state_of_intersecting_invoices(domain_names)
      intersecting_invoices = ReserveDomainInvoice.pending.where('domain_names && ARRAY[?]::varchar[]', domain_names)
      intersecting_invoices.each do |invoice|
        
        result = invoice.invoice_state

        if invoice.pending? && result.paid?

          invoice.paid!
          invoice.create_reserved_domains
          ReserveDomainInvoice.cancel_intersecting_invoices(domain_names)

          return true
        end
      end
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

    def create_invoice_with_domains(domain_names, invoice_number: nil, user_unique_id: nil)
      invoice_number = fetch_invoice_number if invoice_number.nil?
      
      build_invoice(
        total: domain_price_calculation(domain_names),
        number: invoice_number,
        reserved_domain_names: domain_names,
        user_unique_id: user_unique_id
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
        reserved_domain_names: attributes[:reserved_domain_names],
        user_unique_id: attributes[:user_unique_id]
      )
    end

    def generate_unique_id
      SecureRandom.uuid[0..7]
    end

    def process_invoice(invoice)
      EisBilling::AddDeposits.new(invoice).call
    end

    def create_reserve_domain_invoice(invoice_number, domain_names, user_unique_id)
      create(
        invoice_number: invoice_number,
        domain_names: domain_names,
        metainfo: user_unique_id
      )
    end

    def build_response(result, invoice_number, user_unique_id)
      parsed_result = JSON.parse(result.body)
      # link = JSON.parse(result.body)['everypay_link']
      
      InvoiceResponseStruct.new(
        status_code_success: success_status?(result.code),
        oneoff_payment_link: parsed_result['everypay_link'],
        invoice_number: invoice_number,
        user_unique_id: user_unique_id,
        details: parsed_result
      )
    end

    def build_error_response(message)
      InvoiceResponseStruct.new(
        status_code_success: false,
        details: message
      )
    end

    def success_status?(status_code)
      status_code == HTTP_OK || status_code == HTTP_CREATED
    end

    def domain_price_calculation(domain_names)
      domain_names.count * DEFAULT_AMOUNT
    end
  end

  def invoice_state
    EisBilling::GetReservedDomainsInvoiceStatus.call(invoice_number: invoice_number, user_unique_id: metainfo)
  end

  def create_reserved_domains
    domain_names.map { |name| ReservedDomain.create(name: name) if ReservedDomain.find_by(name: name).nil? }
  end

  def build_reserved_domains_output
    domain_names.map { |name| ReservedDomain.where(name: name).pluck(:name, :password).to_h }
  end
end
