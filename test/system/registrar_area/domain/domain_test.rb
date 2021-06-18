require 'application_system_test_case'

class Domainest < ApplicationSystemTestCase
  setup do
    @user = users(:api_bestnames)
    @contact = contacts(:jack)

    @domain = domains(:shop)

    sign_in @user
  end

  def test_update_tech_contact
    visit edit_registrar_domains_path + "?domain_name=#{@domain.name}"
    fill_in 'domain_contacts_attributes_0_code_helper', with: "#{@contact.code} #{@contact.name}"
    click_on 'Save'
    
    assert_redirect_to info_registrar_domains_url(domain_name: @domain_params[:name])
  end
end
