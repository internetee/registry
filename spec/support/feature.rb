module Feature
  def sign_in(user)
    visit root_path
    click_on 'ID card (gitlab)' if user.username == 'gitlab'
    click_on 'ID card (zone)' if user.username == 'zone'
    click_on 'ID card (elkdata)' if user.username == 'elkdata'
  end
end

RSpec.configure do |c|
  c.include Feature, type: :feature
end
