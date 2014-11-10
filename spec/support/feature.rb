module Feature
  def sign_in(user)
    visit '/logout'
    click_on 'ID card (gitlab)' if user.username == 'gitlab'
  end
end

RSpec.configure do |c|
  c.include Feature, type: :feature
end
