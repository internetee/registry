require 'test_helper'

class RecordDateOfTestTest < ActiveSupport::TestCase
  setup do
    @api_bestname = users(:api_bestnames)
    @api_bestname.accreditation_date = Time.zone.now - 10.minutes
    @api_bestname.accreditation_expire_date = @api_bestname.accreditation_date + 1.year
    @api_bestname.save
  end

  def test_should_record_data_to_apiuser
    api_goodname = users(:api_goodnames)

    assert_nil api_goodname.accreditation_date
    assert_nil api_goodname.accreditation_expire_date

    Actions::RecordDateOfTest.record_result_to_api_user(api_user: api_goodname, date: @api_bestname.accreditation_date)

    assert_equal api_goodname.accreditation_date, @api_bestname.accreditation_date
    assert_equal api_goodname.accreditation_expire_date, @api_bestname.accreditation_expire_date
  end
end
