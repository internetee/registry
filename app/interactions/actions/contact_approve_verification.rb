# frozen_string_literal: true

module Actions
  # Registrar manually approves a pending Contact identification.
  class ContactApproveVerification
    SUB_PATTERN = /\A([A-Z]{2})([0-9A-Za-z]+)\z/

    attr_reader :contact

    def initialize(contact)
      @contact = contact
    end

    def call
      unless contact.verification_pending_at.present?
        contact.errors.add(:base, :not_pending_verification)
        return false
      end

      snapshot = (contact.verification_snapshot || {}).with_indifferent_access
      attrs = {
        verified_at: Time.zone.now,
        verification_pending_at: nil,
        verification_snapshot: {}
      }

      if contact.ident_type == Contact::BIRTHDAY
        ident_attrs = birthday_attrs_from_snapshot(snapshot)
        return false if ident_attrs.nil?

        attrs.merge!(ident_attrs)
      else
        subject = snapshot[:sub].to_s.strip.presence
        if subject.blank?
          contact.errors.add(:base, :missing_subject)
          return false
        end

        country_code, ident = parse_subject(subject)
        if country_code.blank? || ident.blank?
          contact.errors.add(:base, :missing_subject)
          return false
        end

        attrs[:ident_country_code] = country_code
        attrs[:ident] = ident
      end

      contact.update!(attrs)
      true
    end

    private

    def birthday_attrs_from_snapshot(snapshot)
      birthdate = snapshot[:birthdate].presence || snapshot[:date_of_birth].presence
      name = snapshot[:name].presence ||
             [snapshot[:given_name], snapshot[:family_name]].compact.join(' ').strip.presence
      country_code = snapshot[:country].to_s.strip.upcase.presence

      if birthdate.blank? || name.blank? || country_code.blank?
        contact.errors.add(:base, :missing_claims)
        return nil
      end

      {
        ident: birthdate,
        name: name,
        ident_country_code: country_code
      }
    end

    def parse_subject(subject)
      match = subject.match(SUB_PATTERN)
      return [nil, nil] unless match

      [match[1], match[2]]
    end
  end
end
