module Serializers
  module Repp
    class ApiUser
      attr_reader :user

      def initialize(user)
        @user = user
      end

      # rubocop:disable Metrics/MethodLength
      def to_json(obj = user)
        json = {
          id: obj.id,
          name: obj.username,
          password: obj.plain_text_password,
          identity_code: obj.identity_code,
          subject: obj.subject,
          email: obj.email,
          roles: obj.roles.join(', '),
          active: obj.active,
          created_at: obj.created_at,
          updated_at: obj.updated_at,
          creator: obj.creator_str,
          updator: obj.updator_str,
          ident_request_sent_at: obj.ident_request_sent_at,
          verified_at: obj.verified_at,
          verification_id: obj.verification_id,
          verification_pending_at: obj.verification_pending_at,
          verification_snapshot: obj.verification_snapshot
        }
        json[:certificates] = certificates
        json
      end
      # rubocop:enable Metrics/MethodLength

      private

      def certificates
        user.certificates.unrevoked.map do |x|
          subject_str = extract_subject(x)
          { id: x.id, subject: subject_str, status: x.status }
        end
      end

      def extract_subject(certificate)
        subject = nil

        if certificate.csr.present?
          begin
            if certificate.parsed_csr
              subject = certificate.parsed_csr.subject.to_s
            end
          rescue StandardError => e
            Rails.logger.warn("Error extracting subject from CSR: #{e.message}")
          end
        end

        if subject.blank? && certificate.crt.present?
          begin
            if certificate.parsed_crt
              subject = certificate.parsed_crt.subject.to_s
            end
          rescue StandardError => e
            Rails.logger.warn("Error extracting subject from CRT: #{e.message}")
          end
        end

        subject.presence || certificate.common_name.presence || 'Unknown'
      end
    end
  end
end
