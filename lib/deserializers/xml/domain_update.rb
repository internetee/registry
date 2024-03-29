require 'deserializers/xml/legal_document'
require 'deserializers/xml/domain'
require 'deserializers/xml/nameserver'
require 'deserializers/xml/dnssec'
module Deserializers
  module Xml
    class DomainUpdate
      attr_reader :frame, :registrar

      def initialize(frame, registrar)
        @frame = frame
        @registrar = registrar
        @legal_document ||= ::Deserializers::Xml::LegalDocument.new(frame).call
      end

      def call
        obj = { domain: frame.css('name')&.text, registrant: registrant, contacts: contacts,
                transfer_code: if_present('authInfo > pw'), nameservers: nameservers,
                registrar_id: registrar, statuses: statuses, dns_keys: dns_keys,
                reserved_pw: if_present('reserved > pw'), legal_document: @legal_document }

        obj.reject { |_key, val| val.blank? }
      end

      def registrant
        return if frame.css('chg > registrant').blank?

        { code: frame.css('chg > registrant').text,
          verified: frame.css('chg > registrant').attr('verified').to_s.downcase == 'yes' }
      end

      def contacts
        contacts = []
        frame.css('add > contact').each do |c|
          contacts << { code: c.text, type: c['type'], action: 'add' }
        end

        frame.css('rem > contact').each do |c|
          contacts << { code: c.text, type: c['type'], action: 'rem' }
        end

        contacts.presence
      end

      def nameservers
        @nameservers = []

        frame.css('add > ns > hostAttr').each { |ns| assign_ns(ns) }
        frame.css('rem > ns > hostAttr').each { |ns| assign_ns(ns, add: false) }

        @nameservers.presence
      end

      def assign_ns(nameserver, add: true)
        nsrv = Deserializers::Xml::Nameserver.new(nameserver).call
        nsrv[:action] = add ? 'add' : 'rem'
        @nameservers << nsrv
      end

      def dns_keys
        added = ::Deserializers::Xml::DnssecKeys.new(frame.css('add')).call
        added.each { |k| k[:action] = 'add' }
        removed = ::Deserializers::Xml::DnssecKeys.new(frame.css('rem'),
                                                       frame.css('name')&.text).call
        removed.each { |k| k[:action] = 'rem' }

        return if (added + removed).blank?

        added + removed
      end

      def statuses
        return if frame.css('status').blank?

        s = []

        frame.css('add > status').each { |e| s << { status: e.attr('s'), action: 'add' } }
        frame.css('rem > status').each { |e| s << { status: e.attr('s'), action: 'rem' } }

        s
      end

      def if_present(css_path)
        return if frame.css(css_path).blank?

        frame.css(css_path).text
      end
    end
  end
end
