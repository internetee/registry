module Actions
  module RecordDateOfTest
    extend self

    TEST_DEADLINE = 1.year.freeze

    def record_result_to_api_user(api_user:, date:)
      p "+++++++++++"
      p api_user
      p "-----------"
      p DateTime.parse(date)
      p "+++++++++++"

      api_user.accreditation_date = date
      api_user.accreditation_expire_date = api_user.accreditation_date + TEST_DEADLINE
      api_user.save

      # api_user.update(accreditation_date: date,
      #                 accreditation_expire_date: DateTime.parse(date) + TEST_DEADLINE)
    end
  end
end
