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
      end

      def call
        obj = { domain: frame.css('name')&.text, registrant: registrant, contacts: contacts,
                auth_info: if_present('pw'), nameservers: nameservers, dns_keys: dns_keys }

        obj.reject { |_key, val| val.blank? }
      end

      def registrant
        return if frame.css('chg > registrant').blank?

        { code: frame.css('chg > registrant').text, verified: frame.css('chg > registrant').attr('verified').to_s.downcase == 'yes' }
      end

      def contacts
        contacts = []
        frame.css('add > contact').each do |c|
          contacts << { code: c.text, type: c['type'], action: 'add' }
        end

        frame.css('rem > contact').each do |c|
          contacts << { code: c.text, type: c['type'], action: 'rem' }
        end

        contacts.present? ? contacts : nil
      end

      def nameservers
        nameservers = []
        frame.css('add > ns > hostAttr').each do |ns|
          nsrv = { nameserver: ns.css('hostName').text, host_addr: [], action: 'add' }
          ns.css('hostAddr').each { |ha| nsrv[:host_addr] << { proto: ha.attr('ip').to_s.downcase, addr: ha.text } }
          nameservers << nsrv
        end

        frame.css('rem > ns > hostAttr').each do |ns|
          nsrv = { nameserver: ns.css('hostName').text, host_addr: [], action: 'rem' }
          ns.css('hostAddr').each { |ha| nsrv[:host_addr] << { proto: ha.attr('ip').to_s.downcase, addr: ha.text } }
          nameservers << nsrv
        end

        nameservers.present? ? nameservers : nil
      end

      def dns_keys
        added = ::Deserializers::Xml::DnssecKeys.new(frame.css('add')).call
        added.each { |k| k[:action] = 'add' }
        removed = ::Deserializers::Xml::DnssecKeys.new(frame.css('rem')).call
        removed.each { |k| k[:action] = 'rem' }

        return unless (added + removed).present?

        added + removed
      end

      def if_present(css_path)
        return if frame.css(css_path).blank?

        frame.css(css_path).text
      end
    end
  end
end
