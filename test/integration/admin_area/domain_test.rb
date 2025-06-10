require 'test_helper'

class Admin::DomainsControllerTest < ApplicationIntegrationTest
    setup do
        sign_in users(:admin)
        @john = contacts(:john)
        @john.update!(ident: '1234-1234') # ident with hyphen
        registrant = @john.becomes(Registrant)
        @domain = domains(:shop)
        @domain.update!(registrant: @john) # make sure the domain is linked to @john
    end

    def test_search_by_hyphenated_registrant_ident_should_succeed
        get admin_domains_path, params: { q: { registrant_ident_matches: '1234-1234' } }
        assert_response :success
        assert_includes @response.body, @domain.name,
        "Search should find domain when searching by hyphenated registrant ident"
    end

    def test_search_by_hyphenated_contact_ident_should_succeed
        get admin_domains_path, params: { q: { contacts_ident_matches: '1234-1234' } }
        assert_response :success
        assert_includes @response.body, @domain.name,
        "Search should find domain when searching by hyphenated contact ident"
    end
end
