class NotifyAccreditationAdminsAndRegistrarsJob < ApplicationJob
  MONTH_BEFORE = 5.minutes.freeze

  def perform
    notify_month_before
    notify_date_is_expired
  end

  def notify_month_before
    prepare_data_month_before.each do |user|
      next if user.registrar.email.nil?

      AccreditationCenterMailer.test_results_will_expired_in_one_month(user.registrar.email).deliver_now
    end
  end

  def notify_date_is_expired
    prepare_data_expired_data.each do |user|
      next if user.registrar.email.nil?

      AccreditationCenterMailer.test_results_are_expired(user.registrar.email).deliver_now
    end
  end

  private

  def prepare_data_month_before
    ApiUser.where('accreditation_expire_date > ? AND accreditation_expire_date < ?',
                  Time.zone.now.beginning_of_day + MONTH_BEFORE,
                  Time.zone.now.end_of_day + MONTH_BEFORE).includes(:registrar)
  end

  def prepare_data_expired_data
    ApiUser.where('accreditation_expire_date < ?', Time.zone.now.beginning_of_day).includes(:registrar)
  end
end
