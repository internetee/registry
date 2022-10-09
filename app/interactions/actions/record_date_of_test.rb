module Actions
  module RecordDateOfTest
    extend self

    TEST_DEADLINE = 1.year.freeze

    def record_result_to_api_user(api_user:, date:)
      api_user.accreditation_date = date
      api_user.accreditation_expire_date = api_user.accreditation_date + TEST_DEADLINE
      api_user.save
    end
  end
end
