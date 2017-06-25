require 'rails_helper'

RSpec.describe 'admin/_menu' do
  before :example do
    allow(view).to receive(:can?).and_return('test')
    allow(view).to receive(:signed_in?).and_return('test')
    allow(view).to receive(:current_user).and_return('test')
  end

  it 'has link to disputes' do
    render
    expect(rendered).to have_link('Disputes', href: admin_disputes_path)
  end
end
