module Deserializers
  module Xml
    class DnssecKey
      attr_reader :frame, :dsa

      KEY_INTERFACE = { flags: 'flags', protocol: 'protocol', alg: 'alg', public_key: 'pubKey' }
      DS_INTERFACE  = { ds_key_tag: 'keyTag', ds_alg: 'alg', ds_digest_type: 'digestType',
                        ds_digest: 'digest' }

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

      def initialize(frame)
        @key_data = []
        @ds_data = []

        # schema validation prevents both in the same parent node
        if frame.css('dsData').present?
          frame.css('dsData').each do |ds_data|
            @ds_data << Deserializers::Xml::DnssecKey.new(ds_data, true).call
          end
        else
          frame.css('keyData').each do |key|
            @key_data << Deserializers::Xml::DnssecKey.new(key, false).call
          end
        end
      end

      def mark_destroy_all(dns_keys)
        # if transition support required mark_destroy dns_keys when has ds/key values otherwise ...
        dns_keys.map { |inf_data| mark(inf_data) }
      end

      def mark_destroy(dns_keys)
        (ds_data.present? ? ds_filter(dns_keys) : kd_filter(dns_keys)).map do |inf_data|
          inf_data.blank? ? nil : mark(inf_data)
        end
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
