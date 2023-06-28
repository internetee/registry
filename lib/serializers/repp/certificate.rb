module Serializers
  module Repp
    class Certificate
      attr_reader :certificate

      def initialize(certificate)
        @certificate = certificate
      end

      def to_json(obj = certificate)
        json = obj.as_json.except('csr', 'crt')
        csr = obj.parsed_csr
        crt = obj.parsed_crt
        json[:csr] = csr_data(csr) if csr
        json[:crt] = crt_data(crt) if crt
        json
      end

      private

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
