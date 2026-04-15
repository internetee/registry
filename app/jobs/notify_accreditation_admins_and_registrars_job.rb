class NotifyAccreditationAdminsAndRegistrarsJob < ApplicationJob
  MONTH_BEFORE = 1.month.freeze

  def perform
    notify_month_before
    notify_date_is_expired
  end

  def notify_month_before
    prepare_data_month_before.each do |registrar|
      next if registrar.email.nil?

      AccreditationMailer.test_results_will_expired_in_one_month(registrar.email).deliver_now
    end
  end

  def notify_date_is_expired
    prepare_data_expired_data.each do |registrar|
      next if registrar.email.nil?

      AccreditationMailer.test_results_are_expired(registrar.email).deliver_now
    end
  end

  private

  def prepare_data_month_before
    Registrar.where('accreditation_expire_date > ? AND accreditation_expire_date < ?',
                  Time.zone.now.beginning_of_day + MONTH_BEFORE,
                  Time.zone.now.end_of_day + MONTH_BEFORE)
  end

  def prepare_data_expired_data
    Registrar.where('accreditation_expire_date < ?', Time.zone.now.beginning_of_day)
  end
end
