module Actions
  class ContactUpdate
    attr_reader :contact, :new_attributes, :legal_document, :ident, :user

    def initialize(contact, new_attributes, legal_document, ident, user)
      @contact = contact
      @new_attributes = new_attributes
      @legal_document = legal_document
      @ident = ident
      @user = user
    end

    def call
      maybe_remove_address
      maybe_update_statuses
      maybe_update_ident if ident.present?
      maybe_attach_legal_doc
      maybe_change_email
      maybe_filtering_old_failed_records
      commit
    end

    def maybe_change_email
      return if Rails.env.test?

      [:regex, :mx].each do |m|
        r = Actions::SimpleMailValidator.run(email: @new_attributes[:email], level: m)

        unless r.success
          contact.add_epp_error('2005', nil, r.errors, I18n.t(:parameter_value_syntax_error))
          @error = true
          return
        end
      end

      true
    end

    def maybe_filtering_old_failed_records
      if contact.validation_events.count > 1
        contact.validation_events.order!(created_at: :asc)
        while contact.validation_events.count >= 1
          contact.validation_events.first.destroy
        end
      end
    end

    def maybe_remove_address
      return if Contact.address_processing?

      new_attributes.delete(:city)
      new_attributes.delete(:zip)
      new_attributes.delete(:street)
      new_attributes.delete(:state)
      new_attributes.delete(:country_code)
    end

    def maybe_update_statuses
      return unless Setting.client_status_editing_enabled

      new_statuses =
        contact.statuses - new_attributes[:statuses_to_remove] + new_attributes[:statuses_to_add]

      new_attributes[:statuses] = new_statuses
    end

    def maybe_attach_legal_doc
      ::Actions::BaseAction.maybe_attach_legal_doc(contact, legal_document)
    end

    def maybe_update_ident
      unless ident.is_a?(Hash)
        contact.add_epp_error('2308', nil, nil, I18n.t('epp.contacts.errors.valid_ident'))
        @error = true
        return
      end

      if contact.identifier.valid?
        submitted_ident = ::Contact::Ident.new(code: ident[:ident],
                                               type: ident[:ident_type],
                                               country_code: ident[:ident_country_code])

        if submitted_ident != contact.identifier
          contact.add_epp_error('2308', nil, nil, I18n.t('epp.contacts.errors.valid_ident'))
          @error = true
        end
      else
        ident_update_attempt = ident[:ident] != contact.ident

        if ident_update_attempt
          contact.add_epp_error('2308', nil, nil, I18n.t('epp.contacts.errors.ident_update'))
          @error = true
        end

        identifier = ::Contact::Ident.new(code: ident[:ident],
                                          type: ident[:ident_type],
                                          country_code: ident[:ident_country_code])

        identifier.validate

        contact.identifier = identifier
        contact.ident_updated_at ||= Time.zone.now
      end
    end

    def commit
      return false if @error

      contact.upid = user.registrar&.id
      contact.up_date = Time.zone.now

      contact.attributes = new_attributes

      email_changed = contact.will_save_change_to_email?
      old_email = contact.email_was
      updated = contact.save

      if updated && email_changed && contact.registrant?
        ContactMailer.email_changed(contact: contact, old_email: old_email).deliver_now
      end

      updated
    end
  end
end
