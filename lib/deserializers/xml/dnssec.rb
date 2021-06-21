module Deserializers
  module Xml
    class DnssecKey
      attr_reader :frame, :dsa

      KEY_INTERFACE = { flags: 'flags', protocol: 'protocol', alg: 'alg',
                        public_key: 'pubKey' }.freeze
      DS_INTERFACE  = { ds_key_tag: 'keyTag', ds_alg: 'alg', ds_digest_type: 'digestType',
                        ds_digest: 'digest' }.freeze

      def initialize(frame, dsa)
        @frame = frame
        @dsa = dsa
      end

      def call
        dsa ? ds_alg_output : xm_copy(frame, KEY_INTERFACE)
      end

      def ds_alg_output
        ds_key = xm_copy(frame, DS_INTERFACE)
        ds_key.merge(xm_copy(frame.css('keyData'), KEY_INTERFACE)) if frame.css('keyData').present?
        ds_key
      end

      def other_alg_output
        xm_copy(frame, KEY_INTERFACE)
      end

      private

      def xm_copy(entry, map)
        result = {}
        map.each do |key, elem|
          result[key] = entry.css(elem).first.try(:text)
        end
        result
      end
    end

    class DnssecKeys
      attr_reader :frame, :key_data, :ds_data

      def initialize(frame, domain_name = nil)
        @key_data = []
        @ds_data = []

        # schema validation prevents both in the same parent node
        if frame.css('dsData').present?
          frame.css('dsData').each { |k| @ds_data << key_from_params(k, dsa: true) }
        end

        if frame.css('all')&.text == 'true'
          keys_from_domain_name(domain_name)
        elsif frame.css('keyData').present?
          frame.css('keyData').each { |k| @key_data << key_from_params(k, dsa: false) }
        end
      end

      def keys_from_domain_name(domain_name)
        domain = Epp::Domain.find_by(name: domain_name)
        return unless domain

        domain.dnskeys.each do |key|
          @key_data << {
            flags: key.flags,
            protocol: key.protocol,
            alg: key.alg,
            public_key: key.public_key,
          }
        end
      end

      def key_from_params(obj, dsa: false)
        Deserializers::Xml::DnssecKey.new(obj, dsa).call
      end

      def call
        key_data + ds_data
      end

      def mark_destroy_all(dns_keys)
        # if transition support required mark_destroy dns_keys when has ds/key values otherwise ...
        dns_keys.map { |inf_data| mark(inf_data) }
      end

      def mark_destroy(dns_keys)
        data = ds_data.present? ? ds_filter(dns_keys) : kd_filter(dns_keys)
        data.each { |inf_data| inf_data.blank? ? nil : mark(inf_data) }
      end

      private

      def ds_filter(dns_keys)
        @ds_data.map do |ds|
          dns_keys.find_by(ds.slice(*DS_INTERFACE.keys))
        end
      end

      def kd_filter(dns_keys)
        @key_data.map do |key|
          dns_keys.find_by(key)
        end
      end

      def mark(inf_data)
        { id: inf_data.id, _destroy: 1 }
      end
    end
  end
end
