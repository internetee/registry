module Actions
  module RecordDateOfTest
    extend self

    def record_result_to_api_user(api_user:, date:)
      api_user.accreditation_date = date
      api_user.accreditation_expire_date = api_user.accreditation_date + ENV.fetch('accr_expiry_months', 24).to_i.months
      api_user.save
    end
  end
end
