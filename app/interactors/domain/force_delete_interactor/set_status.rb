class Domain
  module ForceDeleteInteractor
    class SetStatus < Base
      def call
        domain.force_delete_type = context.type
        context.type == :fast_track ? force_delete_fast_track : force_delete_soft
        domain.save(validate: false)
      end

      def force_delete_fast_track
        domain.force_delete_date = Time.zone.today +
                                   expire_warning_period_days +
                                   redemption_grace_period_days
        domain.force_delete_start = Time.zone.today + 1.day
      end

      def force_delete_soft
        years = (domain.valid_to.to_date - Time.zone.today).to_i / 365
        soft_forcedelete_dates(years) if years.positive?
      end

      def soft_forcedelete_dates(years)
        domain.force_delete_start = domain.valid_to - years.years
        domain.force_delete_date = domain.force_delete_start +
                                   Setting.expire_warning_period.days +
                                   Setting.redemption_grace_period.days
      end

      private

      def redemption_grace_period_days
        Setting.redemption_grace_period.days + 1.day
      end

      def expire_warning_period_days
        Setting.expire_warning_period.days
      end
    end
  end
end
