require 'rails_helper'

RSpec.describe 'admin price expire', settings: false do
  before :example do
    sign_in_to_admin_area
  end

  it 'expires price' do
    price = create(:unexpired_price)

    expect { patch expire_admin_price_path(price); price.reload }
        .to change { price.expired? }.from(false).to(true)
  end

  it 'redirects to :index' do
    price = create(:unexpired_price)

    patch expire_admin_price_path(price)

    expect(response).to redirect_to admin_prices_url
  end
end
