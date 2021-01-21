# admin_epp_logs_path
require 'test_helper'
require 'application_system_test_case'

class AdminEppLogsIntegrationTest < ApplicationSystemTestCase
    setup do
        sign_in users(:admin)
    end

    # def test_helper_test
    #     user = users(:admin)
    #     new_session_id = 'new-session-id'
    
    #     request_xml = <<-XML
    #       <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    #       <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
    #         <command>
    #           <login>
    #             <clID>#{user.username}</clID>
    #             <pw>#{user.plain_text_password}</pw>
    #             <options>
    #               <version>1.0</version>
    #               <lang>en</lang>
    #             </options>
    #             <svcs>
    #               <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
    #               <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
    #               <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
    #               <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
    #             </svcs>
    #           </login>
    #         </command>
    #       </epp>
    #     XML
    #     assert_difference 'EppSession.count' do
    #       post '/epp/session/login', params: { frame: request_xml },
    #            headers: { 'HTTP_COOKIE' => "session=#{new_session_id}" }
    #     end
    #     assert_epp_response :completed_successfully
    #     session = EppSession.last
    #     assert_equal new_session_id, session.session_id
    #     assert_equal user, session.user
    # end

    def test_visit_epp_logs_page
        visit admin_epp_logs_path
        assert_text 'EPP log'
    end

    def test_show_epp_log_page
        sign_out users(:admin)
        sign_in users(:admin)
        visit admin_epp_logs_path
        puts find(:xpath, "//body", match: :first).native
        find(:xpath, "//tbody/tr/td/a", match: :first).click
        assert_text 'Details'
    end

    def test_dates_sort
        Capybara.exact = true
        visit admin_epp_logs_path

        find(:xpath, "//a[contains(text(), 'Created at')]", match: :first).click
        find(:xpath, "//a[contains(text(), 'Created at')]", match: :first).click

        epp_log_date = find(:xpath, "//table/tbody/tr/td[6]", match: :first).text(:all)
        date_now = Date.today.to_s(:db)

        assert_match /#{date_now}/, epp_log_date
    end
    
end