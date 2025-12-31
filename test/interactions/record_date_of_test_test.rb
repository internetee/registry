require 'test_helper'

class RecordDateOfTestTest < ActiveSupport::TestCase
  def setup
    ENV['accr_expiry_months'] = '24'
  end

  def teardown
    ENV.delete('accr_expiry_months')
  end

  def test_should_record_data_to_apiuser
    api_goodname = users(:api_goodnames)
    date = Time.zone.now

    assert_nil api_goodname.accreditation_date
    assert_nil api_goodname.accreditation_expire_date

    Actions::RecordDateOfTest.record_result_to_api_user(api_user: api_goodname, date: date)

    assert_equal api_goodname.accreditation_date, date
    assert_equal api_goodname.accreditation_expire_date, date + ENV.fetch('accr_expiry_months', 24).to_i.months
  end
end
