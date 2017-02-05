require 'rails_helper'

RSpec.describe 'admin/disputes/edit' do
  let(:dispute) { build_stubbed(:dispute) }

  before :example do
    assign(:dispute, dispute)
    stub_template '_form.html.erb' => ''
  end

  describe 'breadcrumbs section' do
    it 'has link to disputes' do
      render
      expect(rendered).to have_link('Disputes', href: admin_disputes_path)
    end

    it 'has current dispute name' do
      render
      expect(rendered).to have_text('')
    end
  end

  it 'has header' do
    render
    expect(rendered).to have_content('Edit dispute')
  end
end
