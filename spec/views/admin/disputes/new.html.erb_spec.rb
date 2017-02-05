require 'rails_helper'

RSpec.describe 'admin/disputes/new' do
  before :example do
    stub_template '_form.html.erb' => ''
  end

  describe 'breadcrumbs section' do
    it 'has link to disputes' do
      render
      expect(rendered).to have_link('Disputes', href: admin_disputes_path)
    end
  end

  it 'has header' do
    render
    expect(rendered).to have_content('New dispute')
  end
end
