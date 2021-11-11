class NotifyAccreditationAdminsAndRegistrarsJob < ApplicationJob
  MONTH_BEFORE = 5.minute.freeze

  def perform
    prepare_data_month_before.each do |user|
      next if user.registrar.email.nil?

      AccreditationCenterMailer.test_results_will_expired_in_one_month(user.registrar.email).deliver_now
    end

    prepare_data_expired_data.each do |user|
      next if user.registrar.email.nil?

      AccreditationCenterMailer.test_results_are_expired(user.registrar.email).deliver_now
    end
  end

  private

  def prepare_data_month_before
    ApiUser.where("accreditation_expire_date > ? AND accreditation_expire_date < ?",
                  Time.now.beginning_of_day + MONTH_BEFORE,
                  Time.now.end_of_day + MONTH_BEFORE).includes(:registrar)
  end

  def prepare_data_expired_data
    ApiUser.where("accreditation_expire_date < ?", Time.now.beginning_of_day).includes(:registrar)
  end
end
