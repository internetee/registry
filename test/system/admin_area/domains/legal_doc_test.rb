require 'application_system_test_case'

class AdminAreaDomainsLegalDocTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    @domain = domains(:shop)
    @document = LegalDocument.create(
      document_type: 'pdf',
      documentable_id: @domain.id,
      documentable_type: 'Domain',
      path: '\zzz\zzz'
    )
  end

  def test_absent_doc_downloading_without_errors
    visit admin_domain_url(@domain)
    assert_nothing_raised do
      click_on "#{@document.created_at}"
    end
  end
end
