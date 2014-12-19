module Feature
  def sign_in(user)
    visit '/logout'
    click_on 'ID card (user1)' if user.username == 'user1'
  end
end

RSpec.configure do |c|
  c.include Feature, type: :feature
end
