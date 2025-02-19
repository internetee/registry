module Serializers
  module Repp
    class Certificate
      attr_reader :certificate

      def initialize(certificate)
        @certificate = certificate
      end

      def to_json(obj = certificate)
        json = obj.as_json.except('csr', 'crt', 'private_key', 'p12')
        csr = obj.parsed_csr
        crt = obj.parsed_crt
        p12 = obj.parsed_p12
        private_key = obj.parsed_private_key

        json[:private_key] = private_key_data(private_key) if private_key
        json[:p12] = p12_data(obj) if obj.p12.present?
        json[:expires_at] = obj.expires_at if obj.expires_at.present?
        
        json[:csr] = csr_data(csr) if csr
        json[:crt] = crt_data(crt) if crt
        
        json
      end

      private

      def private_key_data(key)
        {
          body: key.to_pem,
          type: 'RSA PRIVATE KEY'
        }
      end

      def p12_data(obj)
        {
          body: obj.p12,
          type: 'PKCS12'
        }
      end

      def csr_data(csr)
        {
          version: csr.version,
          subject: csr.subject.to_s,
          alg: csr.signature_algorithm.to_s,
        }
      end

      def crt_data(crt)
        {
          version: crt.version,
          serial: crt.serial.to_s,
          alg: crt.signature_algorithm.to_s,
          issuer: crt.issuer.to_s,
          not_before: crt.not_before,
          not_after: crt.not_after,
          subject: crt.subject.to_s,
          extensions: crt.extensions.map(&:to_s),
        }
      end
    end
  end
end
