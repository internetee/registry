require 'rails_helper'

RSpec.describe 'admin price create', settings: false do
  let!(:zone) { create(:zone, id: 1, origin: 'test') }
  subject(:price) { Billing::Price.first }

  before :example do
    sign_in_to_admin_area
  end

  it 'creates new price' do
    expect { post admin_prices_path, price: attributes_for(:price, zone_id: '1') }
      .to change { Billing::Price.count }.from(0).to(1)
  end

  it 'saves zone' do
    post admin_prices_path, price: attributes_for(:price, zone_id: '1')
    expect(price.zone_id).to eq(1)
  end

  it 'saves operation category' do
    post admin_prices_path, price:
      attributes_for(:price, zone_id: '1', operation_category: Billing::Price.operation_categories.first)
    expect(price.operation_category).to eq(Billing::Price.operation_categories.first)
  end

  it 'saves duration in months' do
    post admin_prices_path, price: attributes_for(:price, zone_id: '1', duration: '3 mons')
    expect(price.duration).to eq('3 mons')
  end

  it 'saves duration in years' do
    post admin_prices_path, price: attributes_for(:price, zone_id: '1', duration: '1 year')
    expect(price.duration).to eq('1 year')
  end

  it 'saves valid_from' do
    post admin_prices_path, price: attributes_for(:price, zone_id: '1', valid_from: '2010-07-06')
    expect(price.valid_from).to eq(Time.zone.parse('06.07.2010'))
  end

  it 'saves valid_to' do
    post admin_prices_path, price: attributes_for(:price, zone_id: '1', valid_to: '2010-07-06')
    expect(price.valid_to).to eq(Time.zone.parse('06.07.2010'))
  end

  it 'redirects to :index' do
    post admin_prices_path, price: attributes_for(:price, zone_id: '1')
    expect(response).to redirect_to admin_prices_url
  end
end
