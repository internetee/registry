require 'rails_helper'

RSpec.describe 'admin/registrars/show' do
  let(:registrar) { build_stubbed(:registrar, website: 'test website') }

  before :example do
    assign(:registrar, registrar)
    stub_template 'shared/_title' => ''
  end

  it 'has website' do
    render
    expect(rendered).to have_text('test website')
  end
end
