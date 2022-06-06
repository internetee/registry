require 'serializers/repp/contact'
module Repp
  module V1
    class ContactsController < BaseController # rubocop:disable Metrics/ClassLength
      before_action :find_contact, only: %i[show update destroy]
      skip_around_action :log_request, only: :search

      api :get, '/repp/v1/contacts'
      desc 'Get all existing contacts'
      def index
        authorize! :check, Epp::Contact
        records = current_user.registrar.contacts

        q = records.ransack(search_params)
        q.sorts = 'created_at desc' if q.sorts.empty?
        contacts = q.result(distinct: true)

        limited_contacts = contacts.limit(limit).offset(offset)
                                   .includes(:domain_contacts, :registrant_domains, :registrar)

        render_success(data: { contacts: serialized_contacts(limited_contacts),
                               count: contacts.count, statuses: Contact::STATUSES,
                               ident_types: Contact::Ident.types })
      end

      # rubocop:disable Metrics/MethodLength
      api :get, '/repp/v1/contacts/search(/:id)'
      desc 'Search all existing contacts by optional id or query param'
      def search
        scope = current_user.registrar.contacts
        if params[:query]
          escaped_str = ActiveRecord::Base.connection.quote_string params[:query]
          scope = scope.where("name ilike '%#{escaped_str}%' OR code ilike '%#{escaped_str}%'
                               OR ident ilike '%#{escaped_str}%'")
        elsif params[:id]
          scope = scope.where(code: params[:id])
        end

        render_success(data: scope.limit(10)
                                  .map do |c|
                                    { value: c.code,
                                      label: "#{c.code} #{c.name}",
                                      selected: scope.size == 1 }
                                  end)
      end
      # rubocop:enable Metrics/MethodLength

      api :get, '/repp/v1/contacts/:contact_code'
      desc 'Get a specific contact'
      def show
        authorize! :check, Epp::Contact

        simple = params[:simple] == 'true' || false
        serializer = Serializers::Repp::Contact.new(@contact,
                                                    show_address: Contact.address_processing?,
                                                    domain_params: domain_filter_params,
                                                    simplify: simple)

        render_success(data: { contact: serializer.to_json })
      end

      api :get, '/repp/v1/contacts/check/:contact_code'
      desc 'Check contact code availability'
      def check
        contact = Epp::Contact.find_by(code: params[:id])
        data = { contact: { id: params[:id], available: contact.nil? } }

        render_success(data: data)
      end

      api :POST, '/repp/v1/contacts'
      desc 'Create a new contact'
      def create
        @contact = Epp::Contact.new(contact_params_with_address, current_user.registrar, epp: false)
        action = Actions::ContactCreate.new(@contact, contact_params[:legal_document],
                                            contact_ident_params)

        unless action.call
          handle_errors(@contact)
          return
        end

        render_success(**create_update_success_body)
      end

      api :PUT, '/repp/v1/contacts/:contact_code'
      desc 'Update existing contact'
      def update
        action = Actions::ContactUpdate.new(@contact, contact_params_with_address(required: false),
                                            contact_params[:legal_document],
                                            contact_ident_params(required: false), current_user)

        unless action.call
          handle_errors(@contact)
          return
        end

        render_success(**create_update_success_body)
      end

      api :DELETE, '/repp/v1/contacts/:contact_code'
      desc 'Delete a specific contact'
      def destroy
        action = Actions::ContactDelete.new(@contact, params[:legal_document])
        unless action.call
          handle_errors(@contact)
          return
        end

        render_success
      end

      private

      def index_params
        params.permit(:id, :limit, :offset, :details, :q, :simple,
                      :page, :per_page, :domain_filter,
                      domain_filter: [],
                      q: %i[s name_matches code_eq ident_matches ident_type_eq
                            email_matches country_code_eq types_contains_array
                            updated_at_gteq created_at_gteq created_at_lteq
                            statuses_contains_array] + [s: []])
      end

      def search_params
        index_params.fetch(:q, {})
      end

      def domain_filter_params
        filter_params = index_params.slice(:id, :page, :per_page, :domain_filter).to_h
        filter_params.merge!({ sort: hashify(index_params[:q].fetch(:s)) }) if index_params[:q]
        filter_params
      end

      def hashify(sort)
        return unless sort

        sort_hash = {}
        if sort.is_a?(Array)
          sort.each do |s|
            sort_hash.merge!(Hash[*s.split(' ')])
          end
        else
          sort_hash.merge!(Hash[*sort.split(' ')])
        end
        sort_hash
      end

      def limit
        index_params[:limit] || 200
      end

      def offset
        index_params[:offset] || 0
      end

      def serialized_contacts(contacts)
        return contacts.map(&code) unless index_params[:details] == 'true'

        address_processing = Contact.address_processing?
        contacts.map do |c|
          Serializers::Repp::Contact.new(c, show_address: address_processing).to_json
        end
      end

      def contact_addr_present?
        return false unless contact_addr_params

        contact_addr_params.keys.any?
      end

      def create_update_success_body
        { code: opt_addr? ? 1100 : nil,
          data: { contact: { code: @contact.code } },
          message: opt_addr? ? I18n.t('epp.contacts.completed_without_address') : nil }
      end

      def opt_addr?
        !Contact.address_processing? && contact_addr_present?
      end

      def find_contact
        code = params[:id]
        @contact = Epp::Contact.find_by!(code: code, registrar: current_user.registrar)
      end

      def contact_params_with_address(required: true)
        return contact_create_params(required: required) unless contact_addr_present?

        contact_create_params(required: required).merge(contact_addr_params)
      end

      def contact_create_params(required: true)
        create_params = %i[name email phone]
        contact_params.require(create_params) if required
        contact_params.slice(*create_params)
      end

      def contact_ident_params(required: true)
        ident_params = %i[ident ident_type ident_country_code]
        contact_params.require(:ident).require(ident_params) if required
        contact_params[:ident].to_h
      end

      def contact_addr_params
        return contact_params[:addr] unless Contact.address_processing?

        addr_params = %i[country_code city street zip]
        contact_params.require(:addr).require(addr_params)
        contact_params[:addr]
      end

      def contact_params
        params.require(:contact).permit(:name, :email, :phone, :legal_document,
                                        legal_document: %i[body type],
                                        ident: [%i[ident ident_type ident_country_code]],
                                        addr: [%i[country_code city street zip state]])
      end
    end
  end
end
