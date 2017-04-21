require 'rails_helper'

RSpec.describe 'admin zone update' do
  before :example do
    sign_in_to_admin_area
  end

  text_attributes = %i[origin email master_nameserver]
  integer_attributes = %i[ttl refresh retry expire minimum_ttl]

  text_attributes.each do |attr_name|
    it "updates #{attr_name}" do
      zone = create(:zone, attr_name => 'test')

      patch admin_zone_path(zone), zone: attributes_for(:zone, attr_name => 'new-test')
      zone.reload

      expect(zone.send(attr_name)).to eq('new-test')
    end
  end

  integer_attributes.each do |attr_name|
    it "updates #{attr_name}" do
      zone = create(:zone, attr_name => '1')

      patch admin_zone_path(zone), zone: attributes_for(:zone, attr_name => '2')
      zone.reload

      expect(zone.send(attr_name)).to eq(2)
    end
  end

  it 'redirects to :index' do
    zone = create(:zone)

    patch admin_zone_path(zone), { zone: attributes_for(:zone) }

    expect(response).to redirect_to admin_zones_url
  end
end
