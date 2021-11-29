module Actions
  module RecordDateOfTest
    extend self

    TEST_DEADLINE = 1.year.freeze

    def record_result_to_api_user(api_user, date)
      api_user.update(accreditation_date: date,
                      accreditation_expire_date: date + TEST_DEADLINE)
    end
  end
end
