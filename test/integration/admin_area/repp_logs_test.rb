require 'test_helper'
require 'application_system_test_case'

class AdminAreaReppLogsIntegrationTest < JavaScriptApplicationSystemTestCase

    setup do
        WebMock.allow_net_connect!
        sign_in users(:admin)

        @logs = ApiLog::ReppLog
    end

    # TODO

    # Helpers ================================================

    # def clear_repp_logs
    #     @logs.delete_all
    # end

    # def visit_and_add_some_repp_log
    #     # clear_repp_logs

    #     visit admin_repp_logs_path
    #     assert_text 'REPP log'

    #     get repp_v1_contacts_path

    #     visit admin_repp_logs_path
    #     assert_text 'REPP log'

    #     find(:xpath, "//table/tbody/tr/td/a", match: :first).click
    # end

    # # Tests ==================================================

    # def test_visit_repp_logs
    #     visit_and_add_some_repp_log
    #     # p find(:xpath, "//table").native.attribute('outerHTML')
    # end

end