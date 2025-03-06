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
          roles: obj.roles.join(', '),
          active: obj.active,
          accredited: obj.accredited?,
          accreditation_expired: obj.accreditation_expired?,
          accreditation_expire_date: obj.accreditation_expire_date,
          created_at: obj.created_at,
          updated_at: obj.updated_at,
          creator: obj.creator_str,
          updator: obj.updator_str,
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
