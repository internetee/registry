require 'rails_helper'

RSpec.describe 'admin price destroy', settings: false do
  let!(:price) { create(:price) }

  before :example do
    sign_in_to_admin_area
  end

  it 'deletes price' do
    expect { delete admin_price_path(price) }.to change { Billing::Price.count }.from(1).to(0)
  end

  it 'redirects to :index' do
    delete admin_price_path(price)
    expect(response).to redirect_to admin_prices_url
  end
end
