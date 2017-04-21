require 'rails_helper'

RSpec.describe 'admin zone destroy', settings: false do
  let!(:zone) { create(:zone) }

  before :example do
    sign_in_to_admin_area
  end

  it 'deletes zone' do
    expect { delete admin_zone_path(zone) }.to change { DNS::Zone.count }.from(1).to(0)
  end

  it 'redirects to :index' do
    delete admin_zone_path(zone)
    expect(response).to redirect_to admin_zones_url
  end
end
