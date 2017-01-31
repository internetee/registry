module Features
  module SessionHelpers
    def sign_in_to_admin_area(user: FactoryGirl.create(:admin_user))
      visit admin_login_url

      fill_in 'admin_user[username]', with: user.username
      fill_in 'admin_user[password]', with: user.password

      click_button 'Log in'
    end

    def sign_in_to_registrar_area(user: FactoryGirl.create(:api_user))
      visit registrar_login_url

      fill_in 'depp_user_tag', with: user.username
      fill_in 'depp_user_password', with: user.password

      click_button 'Login'
    end
  end
end
