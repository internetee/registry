module Features
  module SessionHelpers
    def sign_in_to_registrar_area(user: FactoryGirl.create(:api_user))
      visit registrar_login_path

      fill_in 'depp_user_tag', with: user.username
      fill_in 'depp_user_password', with: user.password

      click_button 'Login'
    end
  end
end
