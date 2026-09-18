module ApiUsers
  module SubjectBackfill
    module_function

    def run
      updated = 0
      skipped = 0

      ApiUser.where(subject: [nil, ''])
             .where.not(identity_code: [nil, ''])
             .find_each do |user|
        country = user.country_code.presence || 'EE'
        subject = "#{country}#{user.identity_code}"

        if ApiUser.where(registrar_id: user.registrar_id, subject: subject)
                  .where.not(id: user.id)
                  .exists?
          skipped += 1
          Rails.logger.warn(
            "api_user subject backfill skipped user_id=#{user.id} " \
            "registrar_id=#{user.registrar_id} subject=#{subject} (conflict)"
          )
          next
        end

        user.update_columns(subject: subject)
        updated += 1
      end

      { updated: updated, skipped: skipped }
    end
  end
end
