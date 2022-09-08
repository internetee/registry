module Domains
  module ForceDelete
    class SetStatus < Base
      def execute
        domain.force_delete_type = type
        type == :fast_track ? force_delete_fast_track : force_delete_soft
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
        years.positive? ? soft_forcedelete_dates(years) : set_less_than_year_until_valid_to_date
      end

      private

      def soft_forcedelete_dates(years)
        domain.force_delete_start = domain.valid_to - years.years
        domain.force_delete_date = domain.force_delete_start +
                                   expire_warning_period_days +
                                   redemption_grace_period_days
      end

      def set_less_than_year_until_valid_to_date
        domain.force_delete_start = domain.valid_to
        domain.force_delete_date = domain.force_delete_start +
                                   expire_warning_period_days +
                                   redemption_grace_period_days
      end

      def redemption_grace_period_days
        Setting.redemption_grace_period.days
      end

      def expire_warning_period_days
        Setting.expire_warning_period.days
      end
    end
  end
end
