module Feature
  def sign_in(user)
    visit '/admin/logout'

    if user.username == 'user1'
      fill_in 'admin_user_username', with: 'user1' 
      fill_in 'admin_user_password', with: 'testtest'
    end
    if user.username == 'gitlab'
      fill_in 'admin_user_username', with: 'gitlab' 
      fill_in 'admin_user_password', with: 'ghyt9e4fu'
    end

    click_on 'Log in'
  end
end

RSpec.configure do |c|
  c.include Feature, type: :feature
end
