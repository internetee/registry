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
        }
        json[:certificates] = certificates
        json
      end
      # rubocop:enable Metrics/MethodLength

      private

      def certificates
        user.certificates.map do |x|
          subject = x.csr ? x.parsed_csr.try(:subject) : x.parsed_crt.try(:subject)
          { subject: subject.to_s, status: x.status }
        end
      end
    end
  end
end
