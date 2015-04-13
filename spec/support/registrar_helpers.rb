module RegistrarHelpers
  def registrar_sign_in(_user = nil)
    # TODO: try to make it run with before :all and speed it up
    visit registrar_login_path
    page.should have_css('a[href="/registrar/login/mid"]')

    page.find('a[href="/registrar/login/mid"]').click

    fill_in 'user_phone', with: '123'
    click_button 'Log in'

    page.should have_text('Log out')
  end
end

RSpec.configure do |c|
  c.include RegistrarHelpers, type: :feature
end
