class Domain
  module ForceDelete
    class SetStatus
      include Interactor

      def call
        domain.force_delete_type = context.type
        context.type == :fast_track ? force_delete_fast_track : force_delete_soft
        domain.save(validate: false)
      end

      private

      def domain
        @domain |= context.domain
      end

      def force_delete_fast_track
        domain.force_delete_date = Time.zone.today +
                                   Setting.expire_warning_period.days +
                                   Setting.redemption_grace_period.days +
                                   1.day
        domain.force_delete_start = Time.zone.today + 1.day
      end

      def force_delete_soft
        years = (valid_to.to_date - Time.zone.today).to_i / 365
        soft_forcedelete_dates(years)
      end

      def soft_forcedelete_dates(years)
        domain.force_delete_start = domain.valid_to - years.years
        domain.force_delete_date = domain.force_delete_start +
                                   Setting.expire_warning_period.days +
                                   Setting.redemption_grace_period.days
      end
    end
  end
end
