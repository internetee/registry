require 'rails_helper'

RSpec.describe 'admin zone create', settings: false do
  subject(:zone) { DNS::Zone.first }

  before :example do
    sign_in_to_admin_area
  end

  it 'creates new zone' do
    expect { post admin_zones_path, zone: attributes_for(:zone) }
      .to change { DNS::Zone.count }.from(0).to(1)
  end

  text_attributes = %i[origin email master_nameserver ns_records a_records a4_records]
  integer_attributes = %i[ttl refresh retry expire minimum_ttl]

  text_attributes.each do |attr_name|
    it "saves #{attr_name}" do
      post admin_zones_path, zone: attributes_for(:zone, attr_name => 'test')
      expect(zone.send(attr_name)).to eq('test')
    end
  end

  integer_attributes.each do |attr_name|
    it "saves #{attr_name}" do
      post admin_zones_path, zone: attributes_for(:zone, attr_name => '1')
      expect(zone.send(attr_name)).to eq(1)
    end
  end

  it 'redirects to :index' do
    post admin_zones_path, zone: attributes_for(:zone)
    expect(response).to redirect_to admin_zones_url
  end
end
