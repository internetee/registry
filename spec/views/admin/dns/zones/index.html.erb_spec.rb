require 'rails_helper'

RSpec.describe 'admin/dns/zones/index' do
  let(:zones) { [] }

  before :example do
    assign(:zones, zones)
    stub_template '_zone.html.erb' => 'zone-row'
  end

  it 'has title' do
    render
    expect(rendered).to have_text(t('admin.dns.zones.index.title'))
  end

  context 'when zones are present' do
    let(:zones) { [build_stubbed(:zone)] }

    it 'has zone row' do
      render
      expect(rendered).to have_text('zone-row')
    end

    it 'has no :not_found message' do
      render
      expect(rendered).to_not have_text(not_found_message)
    end
  end

  context 'when zones are absent' do
    it 'has :not_found message' do
      render
      expect(rendered).to have_text(not_found_message)
    end
  end

  def not_found_message
    t('admin.dns.zones.index.not_found')
  end
end
